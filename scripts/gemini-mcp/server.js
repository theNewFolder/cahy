#!/usr/bin/env node
// Gemini MCP Server — zero-dependency Node.js server
// Exposes a gemini_ask tool via the Model Context Protocol
// Used by Claude Code to query Gemini for second opinions

const { execSync } = require('child_process');
const readline = require('readline');

const rl = readline.createInterface({ input: process.stdin });

// MCP protocol handler
function handleMessage(msg) {
  const { id, method, params } = msg;

  switch (method) {
    case 'initialize':
      return {
        jsonrpc: '2.0',
        id,
        result: {
          protocolVersion: '2024-11-05',
          capabilities: { tools: {} },
          serverInfo: { name: 'gemini-mcp', version: '1.0.0' }
        }
      };

    case 'notifications/initialized':
      return null; // No response needed

    case 'tools/list':
      return {
        jsonrpc: '2.0',
        id,
        result: {
          tools: [{
            name: 'gemini_ask',
            description: 'Ask Google Gemini a question. Use for second opinions, research, or when you need another AI perspective.',
            inputSchema: {
              type: 'object',
              properties: {
                prompt: {
                  type: 'string',
                  description: 'The question or prompt to send to Gemini'
                }
              },
              required: ['prompt']
            }
          }]
        }
      };

    case 'tools/call':
      if (params.name === 'gemini_ask') {
        try {
          const prompt = params.arguments.prompt;
          // Use gemini CLI if available, fall back to curl
          let result;
          try {
            result = execSync(`echo ${JSON.stringify(prompt)} | gemini`, {
              encoding: 'utf-8',
              timeout: 60000,
              env: { ...process.env }
            }).trim();
          } catch {
            result = 'Gemini CLI not available. Install with: npm install -g @google/generative-ai-cli';
          }
          return {
            jsonrpc: '2.0',
            id,
            result: {
              content: [{ type: 'text', text: result }]
            }
          };
        } catch (err) {
          return {
            jsonrpc: '2.0',
            id,
            result: {
              content: [{ type: 'text', text: `Error: ${err.message}` }],
              isError: true
            }
          };
        }
      }
      return {
        jsonrpc: '2.0',
        id,
        error: { code: -32601, message: `Unknown tool: ${params.name}` }
      };

    default:
      return {
        jsonrpc: '2.0',
        id,
        error: { code: -32601, message: `Unknown method: ${method}` }
      };
  }
}

// Read JSON-RPC messages from stdin
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

process.stderr.write('Gemini MCP server started\n');
