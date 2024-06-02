from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/')
def index():
    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Python Editor</title>
    </head>
    <body>
        <h1>Python Editor</h1>
        <textarea id="code" rows="10" cols="80"># Escribe tu código Python aquí...</textarea><br><br>
        <button onclick="runCode()">Ejecutar</button><br><br>
        <div id="output"></div>

        <script type="text/javascript">
            function runCode() {
                let code = document.getElementById('code').value;
                fetch('/run', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ code: code })
                })
                .then(response => response.json())
                .then(data => {
                    document.getElementById('output').innerHTML = '<pre>' + data.output + '</pre>';
                })
                .catch(error => {
                    console.error('Error:', error);
                    document.getElementById('output').innerHTML = '<pre>Error: ' + error.message + '</pre>';
                });
            }
        </script>
    </body>
    </html>
    '''

@app.route('/run', methods=['POST'])
def run_code():
    req_data = request.get_json()
    code = req_data['code']

    try:
        result = subprocess.run(['python3', '-c', code], capture_output=True, text=True, timeout=5)
        output = result.stdout.strip()
        return jsonify({'output': output})
    except subprocess.TimeoutExpired:
        return jsonify({'output': 'Timeout Error: Execution timed out.'})
    except subprocess.CalledProcessError as e:
        return jsonify({'output': f'Error: {e.output}'})
    except Exception as e:
        return jsonify({'output': f'Error: {str(e)}'})

if __name__ == '__main__':
    app.run(debug=True)
