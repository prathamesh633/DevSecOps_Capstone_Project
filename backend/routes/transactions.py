from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models import db, Transaction

transactions_bp = Blueprint('transactions', __name__)

@transactions_bp.route('/', methods=['GET'])
@jwt_required()
def get_transactions():
    user_id = get_jwt_identity()
    transactions = Transaction.query.filter_by(user_id=user_id).all()
    return jsonify([t.to_dict() for t in transactions]), 200

@transactions_bp.route('/', methods=['POST'])
@jwt_required()
def add_transaction():
    user_id = get_jwt_identity()
    data = request.get_json()
    
    amount = data.get('amount')
    type = data.get('type')
    category = data.get('category')
    date = data.get('date')

    new_transaction = Transaction(
        amount=amount,
        type=type,
        category=category,
        date=date,
        user_id=user_id
    )
    db.session.add(new_transaction)
    db.session.commit()

    return jsonify(new_transaction.to_dict()), 201

@transactions_bp.route('/<int:id>', methods=['DELETE'])
@jwt_required()
def delete_transaction(id):
    user_id = get_jwt_identity()
    transaction = Transaction.query.filter_by(id=id, user_id=user_id).first()

    if not transaction:
        return jsonify({"msg": "Transaction not found"}), 404

    db.session.delete(transaction)
    db.session.commit()

    return jsonify({"msg": "Transaction deleted"}), 200

@transactions_bp.route('/summary', methods=['GET'])
@jwt_required()
def get_summary():
    user_id = get_jwt_identity()
    # Optional: Filter by month if query param provided
    month = request.args.get('month') 
    
    query = Transaction.query.filter_by(user_id=user_id)
    if month:
        # Assuming date format YYYY-MM-DD
        query = query.filter(Transaction.date.startswith(month))
        
    transactions = query.all()
    
    total_income = sum(t.amount for t in transactions if t.type == 'income')
    total_expense = sum(t.amount for t in transactions if t.type == 'expense')
    balance = total_income - total_expense

    return jsonify({
        "total_income": total_income,
        "total_expense": total_expense,
        "balance": balance
    }), 200
