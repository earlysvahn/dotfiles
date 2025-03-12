#!/bin/bash

DB_FILE="./task_data.db"

sqlite3 $DB_FILE <<EOF

CREATE TABLE IF NOT EXISTS llm_model (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    llm_id TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    source TEXT NOT NULL,  -- Specifies whether the model is available in Ollama, OpenAI API, etc.
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS event_summary (
    event_name TEXT PRIMARY KEY,
    summary TEXT,
    reminder TEXT,
    llm_id TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (llm_id) REFERENCES llm_model(llm_id)
);

-- Ensure default LLM models are inserted
INSERT OR IGNORE INTO llm_model (llm_id, name, description, source) VALUES 
    -- Available in Ollama (Local models)
    ('mistral', 'Mistral', 'A powerful LLM for text processing.', 'ollama'),
    ('mixtral', 'Mixtral', 'A mixture-of-experts model from Mistral AI.', 'ollama'),
    ('llama3.2', 'Llama 3', 'Metas open-weight LLM.', 'ollama'),
    ('gemma', 'Gemma', 'Google DeepMinds lightweight LLM.', 'ollama'),
    ('phi-2', 'Phi-2', 'A small, efficient model by Microsoft.', 'ollama'),

    -- Requires OpenAI API
    ('gpt-4-turbo', 'GPT-4 Turbo', 'A fast, cost-effective version of GPT-4.', 'openai_api'),
    ('gpt-4', 'GPT-4', 'OpenAIs flagship LLM.', 'openai_api'),
    ('gpt-3.5-turbo', 'GPT-3.5 Turbo', 'A lightweight alternative to GPT-4.', 'openai_api'),

    -- Requires Anthropic API
    ('command-r', 'Command R', 'Anthropics Claude model optimized for reasoning.', 'anthropic_api'),
    ('claude-3', 'Claude 3', 'Anthropics latest LLM optimized for deep reasoning.', 'anthropic_api'),

    -- Requires Hugging Face or Self-Hosting
    ('orca-2', 'Orca 2', 'Microsofts model for reasoning tasks.', 'huggingface'),
    ('falcon-180b', 'Falcon 180B', 'A high-performance LLM from TII.', 'huggingface'),
    ('mpt-7b', 'MPT-7B', 'MosaicMLs lightweight open model.', 'huggingface');
EOF

echo "Database schema ensured with default LLM models and source information."
