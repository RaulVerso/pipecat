FROM python:3.11.5-slim

WORKDIR /app

# 1) Atualiza pip e instala libs de sistema
RUN python -m pip install --upgrade pip setuptools wheel && \
    apt-get update && \
    apt-get install -y \
      libgl1-mesa-glx \
      libglib2.0-0 \
      ffmpeg \
      libssl-dev \
      libasound2 \
      wget && \
    rm -rf /var/lib/apt/lists/*

# 2) Instala dependências Python (incluindo opencv-python-headless)
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# 3) Copia e instala o pacote local
COPY pyproject.toml setup.py /app/
RUN pip install .

# 4) Copia o restante do código
COPY src/ /app/src/
COPY examples/ /app/examples/

EXPOSE 8000
CMD ["gunicorn", "--workers=2", "--log-level","debug", \
     "--chdir","examples/server", "--capture-output", \
     "daily-bot-manager:app", "--bind=0.0.0.0:8000"]
