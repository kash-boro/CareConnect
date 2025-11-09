from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt

db = SQLAlchemy()
bcrypt = Bcrypt()
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///CC.db'  # or your database URI
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Define your User model
class User(db.Model):
    __tablename__ = 'customer'
    
    id = db.Column(db.Integer, primary_key=True)
    C_name = db.Column(db.String(50), unique=True, nullable=False)  # Username field
    password = db.Column(db.String(50), nullable=False)

# Route for login
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    C_name = data.get('C_name')
    password = data.get('password')

    user = User.query.filter_by(C_name=C_name).first()
    if user and user.password == password:
        return jsonify({"status": "success"}), 200
    else:
        return jsonify({"status": "fail", "message": "Invalid username or password"}), 401

if __name__ == '__main__':
    app.run(debug=True)

class User(db.Model):
    reg_id = db.Column(db.Integer, primary_key=True)
    C_mail = db.Column(db.String(50), unique=True, nullable=False)
    C_name = db.Column(db.String(50), nullable=True)
    C_phone = db.Column(db.Integer, nullable=True)
    C_DOB = db.Column(db.Date, nullable=True)
    C_addr = db.Column(db.String(50), nullable=True)
    reg_stat = db.Column(db.String(15), nullable=True, default="active")
    reg_date = db.Column(db.Date, nullable=True, default=datetime.utcnow)
    password = db.Column(db.String(120), nullable=False)

    def __init__(self, C_mail, password, C_name=None, C_phone=None, C_DOB=None, C_addr=None):
        self.C_mail = C_mail
        self.password = bcrypt.generate_password_hash(password).decode('utf-8')
        self.C_name = C_name
        self.C_phone = C_phone
        self.C_DOB = C_DOB
        self.C_addr = C_addr
class User(db.Model):
    __tablename__ = 'customer'

    id = db.Column(db.Integer, primary_key=True)
    C_name = db.Column(db.String(50), unique=True, nullable=False)  
    password = db.Column(db.String(50), nullable=False)

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    C_name = data.get('C_name')
    password = data.get('password')

    user = User.query.filter_by(C_name=C_name).first()
    if user and user.password == password:
        return jsonify({"status": "success"}), 200
    else:
        return jsonify({"status": "fail", "message": "Invalid username or password"}), 401