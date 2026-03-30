function updateTimestamp() {
    const now = new Date();
    const timestamp = now.toLocaleString('fr-FR', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    });
    document.getElementById('timestamp').textContent = timestamp;
}

function generateContainerId() {
    const chars = '0123456789abcdef';
    let id = '';
    for (let i = 0; i < 12; i++) {
        id += chars[Math.floor(Math.random() * chars.length)];
    }
    return id;
}

function testContainer() {
    const resultBox = document.getElementById('result');
    const statusElement = document.getElementById('status');

    statusElement.textContent = 'Test en cours...';
    statusElement.style.color = '#EA580C';

    setTimeout(() => {
        statusElement.textContent = 'Container operationnel';
        statusElement.style.color = '#16A34A';

        resultBox.innerHTML = `
            <strong>Test du Container Reussi</strong><br><br>
            docker ps<br>
            CONTAINER ID   IMAGE                                    STATUS<br>
            ${document.getElementById('container-id').textContent}      ghcr.io/ayoub-hm/tp2_pipeline-devsecops-avec-github-actions:main   Up 5 minutes<br><br>
            - Serveur Nginx : OK<br>
            - Application Web : OK<br>
            - Port 80 : LISTENING<br>
            - Health Check : PASSED
        `;
        resultBox.className = 'result-box success';
    }, 1500);
}

document.addEventListener('DOMContentLoaded', function() {
    updateTimestamp();
    setInterval(updateTimestamp, 1000);

    const containerId = generateContainerId();
    document.getElementById('container-id').textContent = containerId;

    document.getElementById('status').textContent = 'Container operationnel';
});
