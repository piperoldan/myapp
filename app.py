from datetime import datetime
import time
from flask import Flask, render_template, request, redirect
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

app = Flask(__name__)

# Setup Database connection
db_url = os.getenv('DATABASE_URL')
engine = create_engine(db_url)
Session = sessionmaker(bind=engine)
Base = declarative_base()

class Message(Base):
    __tablename__ = 'messages'
    id = Column(Integer, primary_key=True)
    text = Column(String(100))
    created_at = Column(String(50), default=datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

# --- NEW RETRY LOGIC ---
def init_db():
    retries = 5
    while retries > 0:
        try:
            Base.metadata.create_all(engine)
            print("Successfully connected to the database!")
            return
        except Exception as e:
            print(f"Database not ready yet... retrying in 5 seconds. ({retries} retries left)")
            time.sleep(5)
            retries -= 1
    print("Could not connect to database. Check your config.")

init_db()
# -----------------------

@app.route('/')
def home():
    search_query = request.args.get('search')
    session = Session()
    
    if search_query:
        # This filters the database for messages that "contain" the search text
        messages = session.query(Message).filter(Message.text.contains(search_query)).all()
    else:
        # Otherwise, show everything
        messages = session.query(Message).all()
        
    session.close()
    return render_template('index.html', messages=messages)

@app.route('/add_msg', methods=['POST'])
def add_msg():
    content = request.form.get('content')
    if content:
        session = Session()
        new_msg = Message(text=content)
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

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=4000)