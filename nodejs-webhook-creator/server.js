const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');
const { Configuration, OpenAIApi } = require('openai');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const webhooksFilePath = path.join(__dirname, 'webhooks.json');

// Load existing webhooks
const loadWebhooks = () => {
    if (fs.existsSync(webhooksFilePath)) {
        const data = fs.readFileSync(webhooksFilePath);
        return JSON.parse(data);
    }
    return [];
};

// Save webhooks to file
const saveWebhooks = (webhooks) => {
    fs.writeFileSync(webhooksFilePath, JSON.stringify(webhooks, null, 2));
};

// Load and create webhook endpoints
const createEndpoints = (webhooks) => {
    webhooks.forEach(webhook => {
        app.post(webhook.path, (req, res) => {
            try {
                const handler = new Function('req', 'res', webhook.handler);
                handler(req, res);
                res.status(200).send('Webhook received');
            } catch (error) {
                res.status(500).send(`Error handling webhook: ${error.message}`);
            }
        });
        console.log(`Endpoint created: POST ${webhook.path}`);
    });
};

// Load existing webhooks and create endpoints
const webhooks = loadWebhooks();
createEndpoints(webhooks);

app.get('/webhooks', (req, res) => {
    res.json(webhooks);
});

app.post('/webhooks', (req, res) => {
    const webhooks = loadWebhooks();
    const newWebhook = req.body;
    webhooks.push(newWebhook);
    saveWebhooks(webhooks);
    createEndpoints([newWebhook]);
    res.status(201).send('Webhook created');
});

app.post('/generate-webhook', async(req, res) => {
    const { apiKey, prompt, model } = req.body;
    const configuration = new Configuration({
        apiKey: apiKey
    });
    const openai = new OpenAIApi(configuration);

    const prebuiltPrompt = `
    You are an API that generates webhook configurations. Given a description, generate a webhook configuration in JSON format. The format should be as follows:
    {
        "name": "string",
        "path": "string",
        "handler": "string"
    }
    Here's an example description:
    Description: A webhook that triggers on POST /demo/test/:word and logs the word from the URL.

    Now, generate a webhook configuration for the following description:
    `;

    try {
        const response = await openai.createCompletion({
            model: model,
            prompt: prebuiltPrompt + prompt,
            max_tokens: 200
        });

        const generatedText = response.data.choices[0].text.trim();
        const generatedWebhook = JSON.parse(generatedText);

        res.json(generatedWebhook);
    } catch (error) {
        res.status(500).send(`Error generating webhook: ${error.message}`);
    }
});

app.listen(3000, () => {
    console.log('Server is running on port 3000');
});