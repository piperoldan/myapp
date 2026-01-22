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

Base.metadata.create_all(engine)

@app.route('/')
def home():
    session = Session()
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

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=4000)