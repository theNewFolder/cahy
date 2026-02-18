#!/usr/bin/env node
// Gemini MCP Server — zero-dependency Node.js server
// Exposes gemini_ask and gemini_sync_context tools via MCP
// Used by Claude Code to query Gemini and sync knowledge between AIs

const { execSync } = require('child_process');
const { readFileSync, existsSync } = require('fs');
const { join } = require('path');
const readline = require('readline');

const HOME = process.env.HOME || '/home/dev';
const KNOWLEDGE_DIR = join(HOME, 'ai-knowledge', 'knowledge');

// Load user context for Gemini
function getUserContext() {
  const files = ['profile.org', 'skill-map.org'];
  const parts = [];
  for (const f of files) {
    const p = join(KNOWLEDGE_DIR, f);
    if (existsSync(p)) {
      parts.push(readFileSync(p, 'utf-8').slice(0, 500));
    }
  }
  return parts.length ? parts.join('\n\n') : '';
}

const rl = readline.createInterface({ input: process.stdin });

function handleMessage(msg) {
  const { id, method, params } = msg;

  switch (method) {
    case 'initialize':
      return {
        jsonrpc: '2.0', id,
        result: {
          protocolVersion: '2024-11-05',
          capabilities: { tools: {} },
          serverInfo: { name: 'gemini-mcp', version: '2.0.0' }
        }
      };

    case 'notifications/initialized':
      return null;

    case 'tools/list':
      return {
        jsonrpc: '2.0', id,
        result: {
          tools: [
            {
              name: 'gemini_ask',
              description: 'Ask Google Gemini a question. Automatically injects user context (profile, skills) for personalized responses.',
              inputSchema: {
                type: 'object',
                properties: {
                  prompt: { type: 'string', description: 'The question or prompt to send to Gemini' },
                  inject_context: { type: 'boolean', description: 'Inject user profile/skills context (default: true)' }
                },
                required: ['prompt']
              }
            },
            {
              name: 'gemini_sync_context',
              description: 'Send the current user profile and skill map to Gemini so it has the same context as Claude. Use this to sync knowledge between the two AIs.',
              inputSchema: {
                type: 'object',
                properties: {
                  additional_context: { type: 'string', description: 'Any additional context to include' }
                }
              }
            },
            {
              name: 'gemini_research',
              description: 'Ask Gemini to research a topic in depth. Injects user context and asks for structured output.',
              inputSchema: {
                type: 'object',
                properties: {
                  topic: { type: 'string', description: 'Topic to research' },
                  depth: { type: 'string', description: 'quick or deep (default: quick)' }
                },
                required: ['topic']
              }
            }
          ]
        }
      };

    case 'tools/call': {
      const toolName = params.name;
      const args = params.arguments || {};

      if (toolName === 'gemini_ask') {
        try {
          const context = args.inject_context !== false ? getUserContext() : '';
          const fullPrompt = context
            ? `Context about the user:\n${context}\n\n${args.prompt}`
            : args.prompt;

          const result = execSync(`echo ${JSON.stringify(fullPrompt)} | gemini`, {
            encoding: 'utf-8', timeout: 60000, env: { ...process.env }
          }).trim();

          return { jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: result }] } };
        } catch (err) {
          return { jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: `Gemini error: ${err.message}` }], isError: true } };
        }
      }

      if (toolName === 'gemini_sync_context') {
        try {
          const context = getUserContext();
          const extra = args.additional_context || '';
          const syncPrompt = `Please remember and acknowledge this context about the user I'm working with. Respond with a brief confirmation of what you understand.\n\n${context}\n${extra ? `\nAdditional context:\n${extra}` : ''}`;

          const result = execSync(`echo ${JSON.stringify(syncPrompt)} | gemini`, {
            encoding: 'utf-8', timeout: 60000, env: { ...process.env }
          }).trim();

          return { jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: `Gemini context synced:\n${result}` }] } };
        } catch (err) {
          return { jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: `Sync error: ${err.message}` }], isError: true } };
        }
      }

      if (toolName === 'gemini_research') {
        try {
          const context = getUserContext();
          const depth = args.depth === 'deep' ? 'comprehensive and detailed' : 'concise but informative';
          const researchPrompt = `${context ? `User context:\n${context}\n\n` : ''}Research the following topic and provide a ${depth} summary. Include: key concepts, practical applications, recommended learning resources, and next steps.\n\nTopic: ${args.topic}`;

          const result = execSync(`echo ${JSON.stringify(researchPrompt)} | gemini`, {
            encoding: 'utf-8', timeout: args.depth === 'deep' ? 120000 : 60000, env: { ...process.env }
          }).trim();

          return { jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: result }] } };
        } catch (err) {
          return { jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: `Research error: ${err.message}` }], isError: true } };
        }
      }

      return { jsonrpc: '2.0', id, error: { code: -32601, message: `Unknown tool: ${toolName}` } };
    }

    default:
      return { jsonrpc: '2.0', id, error: { code: -32601, message: `Unknown method: ${method}` } };
  }
}

let buffer = '';
rl.on('line', (line) => {
  buffer += line;
  try {
    const msg = JSON.parse(buffer);
    buffer = '';
    const response = handleMessage(msg);
    if (response) {
      process.stdout.write(JSON.stringify(response) + '\n');
    }
  } catch {
    // Incomplete JSON, keep buffering
  }
});

process.stderr.write('Gemini MCP server v2.0 started (with context sync)\n');
