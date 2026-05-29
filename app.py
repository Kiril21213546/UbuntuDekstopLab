from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify(status="ok", message="Hello from Flask CI/CD! Updated by Jenkins")

@app.route("/health")
def health():
    return jsonify(status="healthy")
