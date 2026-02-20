FROM python:3.12-slim
WORKDIR /app

# 1. Install system dependencies (SSH for Git + sudo for our new user)
RUN apt-get update && apt-get install -y \
    openssh-client \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 2. Create the non-root user "vscode"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# 3. Force wheel upgrade and install python requirements
RUN pip install --no-cache-dir --upgrade pip wheel==0.46.2
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copy the rest of your app
COPY . .

# 5. FIX PERMISSIONS: Ensure the vscode user owns the app files
RUN chown -R $USERNAME:$USER_GID /app

# 6. Switch to the non-root user
USER $USERNAME

EXPOSE 4000
# Persist bash history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R vscode /commandhistory \
    && echo "$SNIPPET" >> "/home/vscode/.bashrc"
CMD ["flask", "run", "--host=0.0.0.0", "--port=4000"]