from flask import Flask, request, make_response, jsonify
import requests

app = Flask(__name__)

@app.get('/<user>/<repo>')
def get_github_version(user, repo):
    res = requests.get(f"https://api.github.com/repos/{user}/{repo}/releases/latest")
    data = res.json()
    try:
        if data['message'] == "Not Found":
            return make_response("{error: unable to find tag_name, repo or user may be incorrect}", 404)
    except:
        KeyError
    return make_response("{latest_version: %s}" % data['tag_name'], 200)


app.run('0.0.0.0', 8080, debug=True)