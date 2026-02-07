import { createQwen } from "qwen-ai-provider-v5";
import { streamText } from "ai";

const qwen = createQwen({
  baseURL: "http://127.0.0.1:8080",
  apiKey: "",
});
const model = qwen.chatModel("");

const stream = streamText({
  model,
  prompt: "Hello, how are you?",
});

for await (const chunk of stream.toUIMessageStream()) {
  console.log(chunk);
}
