import os
import time
from pathlib import Path
from dotenv import load_dotenv
load_dotenv() # This looks for .env in the current directory automatically
from flask import Flask, render_template, request, redirect
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from datetime import datetime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

app = Flask(__name__)

db_url = os.getenv("DATABASE_URL") or (
    f"mysql+pymysql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@172.17.0.1:3306/{os.getenv('DB_NAME')}"
)
print("DATABASE_URL being used:", db_url, flush=True)
engine = create_engine(db_url)
Session = sessionmaker(bind=engine)
Base = declarative_base()

class Message(Base):
    __tablename__ = 'messages'
    id = Column(Integer, primary_key=True)
    text = Column(String(255))
    category = Column(String(50), default="General") # Fixed: Added this
    created_at = Column(DateTime, default=datetime.utcnow)

def init_db():
    retries = 5
    while retries > 0:
        try:
            Base.metadata.create_all(engine)
            return
        except Exception:
            time.sleep(5)
            retries -= 1

_db_inited = False

@app.before_request
def _startup():
    global _db_inited
    if not _db_inited:
        init_db()
        _db_inited = True

@app.route('/')
def home():
    search_query = request.args.get('search')
    session = Session()
    if search_query:
        messages = session.query(Message).filter(Message.text.contains(search_query)).all()
    else:
        messages = session.query(Message).all()
    session.close()
    return render_template('index.html', messages=messages)

@app.route('/add_msg', methods=['POST'])
def add_msg():
    text = request.form.get('msg')
    category = request.form.get('category') 
    if text:
        session = Session()
        new_msg = Message(text=text, category=category) 
        session.add(new_msg)
        session.commit()
        session.close()
    return redirect('/')

@app.route('/delete/<int:msg_id>', methods=['POST'])
def delete_msg(msg_id):
    session = Session()
    msg_to_delete = session.query(Message).get(msg_id)
    if msg_to_delete:
        session.delete(msg_to_delete)
        session.commit()
    session.close()
    return redirect('/')

@app.route('/test_mount')
def test_mount():
    try:
        # We look in the 'target' path we defined in devcontainer.json
        with open('/data-from-host/hello.txt', 'r') as f:
            content = f.read()
        return f"File content from Mac: {content}"
    except Exception as e:
        return f"Could not read file: {str(e)}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=4000, debug=True, use_reloader=False)