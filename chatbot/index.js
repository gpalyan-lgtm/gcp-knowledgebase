const express = require("express");
const bodyParser = require("body-parser");
const fetch = require("node-fetch"); // oder axios
const app = express();

app.use(bodyParser.json());

function sendToWebhook(payload) {
  const WEBHOOK_URL = process.env.WEBHOOK_URL;
  const N8N_USER = process.env.N8N_USER;
  const N8N_PASSWORD = process.env.N8N_PASSWORD;

  const auth = Buffer.from(`${N8N_USER}:${N8N_PASSWORD}`).toString("base64");

  return fetch(WEBHOOK_URL, {
    method: "POST",
    headers: {
      "Authorization": `Basic ${auth}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify(payload)
  });
}

function onMessage(event) {
  const user = event.chat.user;
  const message = event.chat.messagePayload.message;
  const space = event.chat.messagePayload.space;

  sendToWebhook({
    user: user.displayName,
    text: message.argumentText.trim(),
    space: space.name,
    spaceType: space.type,
    timestamp: message.createTime
  });

  return {
    sections: [{
      widgets: [{
        textParagraph: {
          text: `Nachricht '${message.argumentText.trim()}' wurde empfangen und wird verarbeitet.`
        }
      }]
    }]
  };
}

app.post("/", async (req, res) => {
  const event = req.body;
  let response;

  if (event.chat && event.chat.messagePayload) {
    response = onMessage(event);
  } else if (event.type === 'ADDED_TO_SPACE') {
    response = {
      sections: [{widgets: [{textParagraph: {text: `Danke, dass du mich hinzugefügt hast, ${event.user.displayName}!`}}]}]
    };
  } else if (event.type === 'REMOVED_FROM_SPACE') {
    console.log("Bot wurde entfernt von", event.space.name);
    return res.status(200).send();
  }

  res.json(response);
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`Server läuft auf Port ${PORT}`));
