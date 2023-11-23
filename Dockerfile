
# Use the official Python image as the base image
FROM python:3.8

# Install Tor
RUN apt-get update \
    && apt-get install -y tor \
    && apt-get install -y netcat-traditional \
    && echo "ControlPort 9051" >> /etc/tor/torrc \
    && echo HashedControlPassword $(tor --hash-password "my password" | tail -n 1) >> /etc/tor/torrc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN service tor start \
    && service tor status
# Set up the working directory
WORKDIR /app

# Copy the FastAPI application files
COPY . .

# Install FastAPI dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose ports for FastAPI and Tor
EXPOSE 8000
EXPOSE 9050
Expose 9051

# Start Tor service
# CMD ["service", "tor", "start"]

# Wait for Tor to start (you may adjust the sleep duration)
RUN sleep 5

# Renew Tor identity (optional)
# CMD ["sh", "-c", "echo -e 'AUTHENTICATE \"your_password\"\r\nsignal NEWNYM\r\nQUIT' | nc 127.0.0.1 9051"]

# CMD ["sh", "-c","echo \"ControlPort 9051\" >> /etc/tor/torrc"]
# CMD ["sh", "-c","echo HashedControlPassword $(tor --hash-password \"my password\" | tail -n 1) >> /etc/tor/torrc"]

# Start FastAPI
# CMD ["service", "tor", "status"]
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]
CMD service tor start && sleep 5 && uvicorn main:app --host 0.0.0.0 --port 8000
