from datetime import datetime
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_mysql import MySQL  # Use this for Flask-MySQL

app = Flask(__name__)

# MySQL configurations
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'kukiDgreat@123'
app.config['MYSQL_DB'] = 'CC'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
bcrypt = Bcrypt()
mysql = MySQL(app)  # Initialize MySQL

# Define your User model
class User(db.Model):
    __tablename__ = 'customer'

    reg_id = db.Column(db.Integer, primary_key=True)
    C_mail = db.Column(db.String(50), unique=True, nullable=False)
    C_name = db.Column(db.String(50), unique=True, nullable=False)
    C_phone = db.Column(db.String(15), nullable=True)
    C_DOB = db.Column(db.Date, nullable=True)
    C_addr = db.Column(db.String(100), nullable=True)
    reg_stat = db.Column(db.String(15), nullable=True, default="active")
    reg_date = db.Column(db.DateTime, nullable=True, default=datetime.utcnow)
    password = db.Column(db.String(120), nullable=False)

    def __init__(self, C_mail, password, C_name=None, C_phone=None, C_DOB=None, C_addr=None):
        self.C_mail = C_mail
        self.password = bcrypt.generate_password_hash(password).decode('utf-8')
        self.C_name = C_name
        self.C_phone = C_phone
        self.C_DOB = C_DOB
        self.C_addr = C_addr

# Route for user registration
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    C_mail = data.get('C_mail')
    password = data.get('password')
    C_name = data.get('C_name')
    C_phone = data.get('C_phone')
    C_DOB = data.get('C_DOB')
    C_addr = data.get('C_addr')

    existing_user = User.query.filter((User.C_mail == C_mail) | (User.C_name == C_name)).first()
    if existing_user:
        return jsonify({"status": "fail", "message": "User already exists"}), 400

    new_user = User(C_mail=C_mail, password=password, C_name=C_name, C_phone=C_phone, C_DOB=C_DOB, C_addr=C_addr)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({"status": "success", "message": "User registered successfully"}), 201

# Route for login
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    C_name = data.get('C_name')
    password = data.get('password')

    user = User.query.filter_by(C_name=C_name).first()
    if user and bcrypt.check_password_hash(user.password, password):
        return jsonify({"status": "success"}), 200
    else:
        return jsonify({"status": "fail", "message": "Invalid username or password"}), 401

if __name__ == '__main__':
    with app.app_context():
        db.create_all()  # Creates the database tables
    app.run(debug=True)
