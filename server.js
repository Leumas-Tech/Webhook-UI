const express = require('express');
const cors = require('cors');
const axios = require('axios');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const templatesFilePath = path.join(__dirname, 'webhook_templates.json');

// Load existing templates
const loadTemplates = () => {
    if (fs.existsSync(templatesFilePath)) {
        const data = fs.readFileSync(templatesFilePath);
        return JSON.parse(data);
    }
    return [];
};

// Save templates to file
const saveTemplates = (templates) => {
    fs.writeFileSync(templatesFilePath, JSON.stringify(templates, null, 2));
};

app.post('/proxy', async(req, res) => {
    try {
        const response = await axios.post(req.body.url, req.body.payload);
        res.json(response.data);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

app.get('/templates', (req, res) => {
    const templates = loadTemplates();
    res.json(templates);
});

app.post('/templates', (req, res) => {
    const templates = loadTemplates();
    templates.push(req.body);
    saveTemplates(templates);
    res.status(201).send('Template saved');
});

app.listen(3000, () => {
    console.log('Server is running on port 3000');
});