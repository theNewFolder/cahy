# Secrets Setup

API keys are loaded automatically from `~/.secrets/` by the shell at startup.

## Add your keys

```bash
echo 'your-gemini-key' > ~/.secrets/gemini_api_key
echo 'your-anthropic-key' > ~/.secrets/anthropic_api_key
echo 'your-openai-key' > ~/.secrets/openai_api_key
chmod 600 ~/.secrets/*_api_key
```

## How it works

- `modules/secrets.nix` creates `~/.secrets/` with `700` permissions
- At shell startup, all files matching `*_api_key` are loaded as environment variables
- Example: `~/.secrets/gemini_api_key` becomes `$GEMINI_API_KEY`

## Never commit secrets

The `.gitignore` excludes actual key files. Only the directory structure is tracked.
