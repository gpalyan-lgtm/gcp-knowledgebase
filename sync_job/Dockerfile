# Use an official lightweight Python image.
FROM python:3.9-slim

# Set the working directory in the container.
WORKDIR /app

# Copy the requirements file and install dependencies (if any).
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application's code.
COPY . .

# Run the application.
CMD ["python", "main.py"]
