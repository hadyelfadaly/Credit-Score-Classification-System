#DEFINE SAFE DEFAULTS
SAFE_DEFAULTS = {
    "Age": 35, "Annual_Income": 80000.0, "Monthly_Inhand_Salary": 7000.0,
    "Num_Bank_Accounts": 2, "Num_Credit_Card": 3, "Interest_Rate": 8,
    "Num_of_Loan": 1, "Delay_from_due_date": 5, "Num_of_Delayed_Payment": 2,
    "Changed_Credit_Limit": 15.0, "Num_Credit_Inquiries": 1, "Credit_Mix": "Good",
    "Outstanding_Debt": 500.0, "Credit_Utilization_Ratio": 25,
    "Credit_History_Age_Months": 250, "Payment_of_Min_Amount": "No",
    "Total_EMI_per_month": 50.0, "Amount_invested_monthly": 200.0,
    "Payment_Behaviour": "High_spent_Medium_value_payments", "Monthly_Balance": 600.0,
    "Occupation": "Engineer", "Type_of_Loan": "Auto Loan"
}

#FLASK SERVER (Port 5008)

app = Flask(__name__)
CORS(app)

@app.route('/')
def home():
    return render_template('index.html')

# --- ROUTE 1: TRAIN ---
@app.route('/train', methods=['POST'])
def train_route():
    try:
        
        train_creditScore_Model(final_CreditScore) 
        
        return jsonify({'status': 'success', 'message': 'Model Trained & Saved Successfully!'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

# --- ROUTE 2: PREDICT ---
@app.route('/predict', methods=['POST'])
def predict_route():
    try:
        user_input = request.json
        
        # 1. Start with defaults (safety)
        final_data = SAFE_DEFAULTS.copy()
        
        # 2. Overwrite with user input
        final_data.update(user_input)
        
        # 3. Call your existing prediction function
        result = predict_credit_score(final_data)
        
        return jsonify({'status': 'success', 'prediction': result})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)})

def run_app():
    # Using Port 5008 to ensure a fresh connection
    app.run(port=5008, debug=False, use_reloader=False)

threading.Thread(target=run_app).start()
print("App Started! Go to: http://127.0.0.1:5008")