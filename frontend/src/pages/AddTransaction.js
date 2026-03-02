import React, { useState } from 'react';
import api from '../api';
import { useNavigate } from 'react-router-dom';

const AddTransaction = () => {
    const [amount, setAmount] = useState('');
    const [type, setType] = useState('expense');
    const [category, setCategory] = useState('');
    const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            await api.post('/transactions/', {
                amount: parseFloat(amount),
                type,
                category,
                date
            });
            navigate('/dashboard');
        } catch (err) {
            alert('Failed to add transaction');
        }
    };

    return (
        <div className="container mt-5">
            <h2>Add Transaction</h2>
            <form onSubmit={handleSubmit}>
                <div className="mb-3">
                    <label>Amount</label>
                    <input type="number" step="0.01" className="form-control" value={amount} onChange={(e) => setAmount(e.target.value)} required />
                </div>
                <div className="mb-3">
                    <label>Type</label>
                    <select className="form-control" value={type} onChange={(e) => setType(e.target.value)}>
                        <option value="expense">Expense</option>
                        <option value="income">Income</option>
                    </select>
                </div>
                <div className="mb-3">
                    <label>Category</label>
                    <input type="text" className="form-control" value={category} onChange={(e) => setCategory(e.target.value)} required placeholder="e.g., Food, Salary" />
                </div>
                <div className="mb-3">
                    <label>Date</label>
                    <input type="date" className="form-control" value={date} onChange={(e) => setDate(e.target.value)} required />
                </div>
                <button type="submit" className="btn btn-success">Add</button>
            </form>
        </div>
    );
};

export default AddTransaction;
