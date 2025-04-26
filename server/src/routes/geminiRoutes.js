const express = require('express');
const router = express.Router();
const fetch = require('node-fetch');
const authMiddleware = require('../middleware/authMiddleware');


require('dotenv').config(); 

router.post('/suggest-modules', authMiddleware, async (req, res) => {
  const { industry, description } = req.body;

  if (!industry || !description) {
    return res.status(400).json({ message: 'Industry and description are required' });
  }

  try {
    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text:
                    'Imagine you are an expert consultant. Based on the following organization details, kindly suggest a list of modules that might be needed to manage the organization. ' +
                    `Industry: ${industry}, Description: ${description}. ` +
                    'Based on the given description suggest a list of modules in the form of an array. ' +
                    'No additional text should be given in the response. ' +
                    'Text response should strictly contain only the array. Suggest 10 modules. ' +
                    'Example format: [module1, module2, module3]. ' +
                    'Also, provide one more array in which you give all module descriptions. ' +
                    'The format should be like this: [module1 description, module2 description, module3 description]'
                }
              ]
            }
          ]
        }),
      }
    );

    const geminiData = await geminiResponse.json();

    const fullText = geminiData?.candidates?.[0]?.content?.parts?.[0]?.text || "";

    // Try to extract both arrays using RegExp
    const arrayMatches = fullText.match(/\[([^\]]+)\]/g);
    if (!arrayMatches || arrayMatches.length < 2) {
      return res.status(500).json({ message: 'Could not parse module suggestions and descriptions.' });
    }

    const moduleNames = JSON.parse(arrayMatches[0]);
    const moduleDescriptions = JSON.parse(arrayMatches[1]);

    // Combine into array of { name, description }
    const modules = moduleNames.map((name, idx) => ({
      name,
      description: moduleDescriptions[idx] || ''
    }));

    return res.status(200).json({ modules });
  } catch (error) {
    console.error('Gemini API error:', error);
    res.status(500).json({ message: 'Failed to fetch suggestions from Gemini.' });
  }
});


router.post('/suggest-fields', authMiddleware, async (req, res) => {
  const { moduleName, description } = req.body;

  if (!moduleName || !description) {
    return res.status(400).json({ message: 'Module name and description are required' });
  }

  try {
    const geminiResponse = await fetch(`https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=${process.env.GEMINI_API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                text: 'Imagine you are an expert database schema designer. Based on the following module details, kindly suggest a list of fields that might be needed. ' +
                `Module name: ${moduleName}, Description: ${description}. ` +
                'Based on the given description suggest a list of fields in the form of an array. ' +
                'No additional text should be given in the response. ' +
                'Text response should strictly contain only the array. Suggest 10 fields. ' +
                'Example format: [field1, field2, field3]. '
              }
            ]
          }
        ]
      }),
    });

    const geminiData = await geminiResponse.json();

    if (geminiData.candidates && geminiData.candidates.length > 0) {
      const suggestionText = geminiData.candidates[0]?.content?.parts[0]?.text || "";

      let fieldList = [];
      try {
        // Try to parse the string as an array
        fieldList = JSON.parse(suggestionText);
      } catch (err) {
        console.warn('Failed to parse Gemini field list. Raw response:', suggestionText);
        fieldList = suggestionText
          .replace(/[\[\]"']/g, '')
          .split(',')
          .map(item => item.trim())
          .filter(item => item.length > 0);
      }

      return res.status(200).json({ fields: fieldList });
    }

    return res.status(500).json({ message: 'No suggestions returned from Gemini.' });
  } catch (error) {
    console.error('Gemini API error:', error);
    res.status(500).json({ message: 'Failed to fetch suggestions from Gemini.' });
  }
});

router.post('/suggest-field-values', authMiddleware, async (req, res) => {
  const { name, type, moduleName, orgName, orgDescription } = req.body;

  if (!name || !type || !moduleName || !orgName) {
    return res.status(400).json({ message: 'Field name, Field type, Module name, Organization name are required' });
  }

  try {
    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  text:
                    'Imagine you are an expert consultant. Based on the following details, suggest a suitable value. ' +
                    `Org name: ${orgName}, Org description: ${orgDescription}, Module name: ${moduleName}, Field name: ${name}, Field datatype: ${type}. ` +
                    'Based on the given details suggest a suitable value. ' +
                    'No additional text should be given in the response. ' +
                    'Text response should strictly contain only the value. Suggest 1 optimum value suggestion. '
                }
              ]
            }
          ]
        }),
      }
    );

    const geminiData = await geminiResponse.json();

    // Safely extract the text
    const suggestedValue = geminiData?.candidates?.[0]?.content?.parts?.[0]?.text?.trim();

    if (!suggestedValue) {
      return res.status(500).json({ message: 'Failed to get a suggested value from AI' });
    }

    res.json({ value: suggestedValue });
  } catch (error) {
    console.error('Error suggesting field value:', error);
    res.status(500).json({ message: 'Error suggesting field value', error: error.message });
  }
});


module.exports = router;
