import React, { useEffect, useState } from 'react';
import api from '../api';
import { Link } from 'react-router-dom';

const Dashboard = () => {
    const [transactions, setTransactions] = useState([]);
    const [summary, setSummary] = useState({ total_income: 0, total_expense: 0, balance: 0 });

    const fetchData = async () => {
        try {
            const tRes = await api.get('/transactions/');
            const sRes = await api.get('/transactions/summary');
            setTransactions(tRes.data);
            setSummary(sRes.data);
        } catch (err) {
            console.error("Error fetching data", err);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    const handleDelete = async (id) => {
        if (window.confirm("Are you sure?")) {
            await api.delete(`/transactions/${id}`);
            fetchData();
        }
    };

    return (
        <div className="container mt-4">
            <h1>Dashboard</h1>

            <div className="row mb-4">
                <div className="col-md-4">
                    <div className="card text-white bg-success mb-3">
                        <div className="card-header">Income</div>
                        <div className="card-body"><h3>${summary.total_income}</h3></div>
                    </div>
                </div>
                <div className="col-md-4">
                    <div className="card text-white bg-danger mb-3">
                        <div className="card-header">Expenses</div>
                        <div className="card-body"><h3>${summary.total_expense}</h3></div>
                    </div>
                </div>
                <div className="col-md-4">
                    <div className="card text-white bg-info mb-3">
                        <div className="card-header">Balance</div>
                        <div className="card-body"><h3>${summary.balance}</h3></div>
                    </div>
                </div>
            </div>

            <Link to="/add" className="btn btn-primary mb-3">Add Transaction</Link>

            <table className="table table-striped">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Category</th>
                        <th>Type</th>
                        <th>Amount</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    {transactions.map(t => (
                        <tr key={t.id}>
                            <td>{t.date}</td>
                            <td>{t.category}</td>
                            <td>
                                <span className={`badge bg-${t.type === 'income' ? 'success' : 'danger'}`}>
                                    {t.type}
                                </span>
                            </td>
                            <td>${t.amount}</td>
                            <td>
                                <button className="btn btn-sm btn-danger" onClick={() => handleDelete(t.id)}>Delete</button>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

export default Dashboard;
