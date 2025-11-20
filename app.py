from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import os
import google.generativeai as genai

app = Flask(__name__, static_folder='static')
CORS(app)

# Load API key from environment
GENAI_API_KEY = os.environ.get("OPENAI_API_KEY")

if not GENAI_API_KEY:
    raise Exception("OPENAI_API_KEY not found in environment")

# Configure Gemini
genai.configure(api_key=GENAI_API_KEY)

# Use free model
model = genai.GenerativeModel("gemini-1.5-flash")

@app.route('/')
def index():
    return send_from_directory("static", "index.html")

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({"status": "healthy"}), 200


@app.route('/chat', methods=['POST'])
def chat():
    try:
        data = request.json
        messages = data.get("messages", [])

        # Extract last user message
        user_message = ""
        if messages:
            user_message = messages[-1].get("content", "")

        # Call Gemini
        response = model.generate_content(user_message)

        return jsonify({
            "response": response.text,
            "status": "success"
        }), 200

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": str(e), "status": "error"}), 500


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
