document.addEventListener("DOMContentLoaded", () => {
    let transactions = JSON.parse(localStorage.getItem("finance_data")) || [];

    const ui = {
        dateStr: document.getElementById("current-date"),
        balance: document.getElementById("balance-amount"),
        inputDate: document.getElementById("input-date"),
        inputTypeIncome: document.getElementById("type-income"),
        inputTypeExpense: document.getElementById("type-expense"),
        inputComment: document.getElementById("input-comment"),
        inputAmount: document.getElementById("input-amount"),
        btnSave: document.getElementById("btn-save"),
        recentList: document.getElementById("recent-list"),
        historyList: document.getElementById("history-list"),
        btnDetails: document.getElementById("btn-details"),
        fileImport: document.getElementById("file-import"),
        btnClear: document.getElementById("btn-clear")
    };

    const today = new Date().toISOString().split('T')[0];
    ui.inputDate.value = today;
    ui.dateStr.innerText = new Date().toLocaleDateString("uk-UA");

    document.querySelectorAll(".tab-btn").forEach(btn => {
        btn.addEventListener("click", (e) => {
            document.querySelectorAll(".tab-btn").forEach(b => b.classList.remove("active"));
            document.querySelectorAll(".page").forEach(p => p.classList.remove("active"));
            e.currentTarget.classList.add("active");
            document.getElementById(e.currentTarget.dataset.target).classList.add("active");
        });
    });

    ui.btnDetails.addEventListener("click", () => document.querySelector('[data-target="history"]').click());
    document.querySelectorAll('.btn-back').forEach(btn => btn.addEventListener("click", () => document.querySelector('[data-target="dashboard"]').click()));

    function saveState() {
        localStorage.setItem("finance_data", JSON.stringify(transactions));
        updateUI();
    }

    function updateUI() {
        transactions.sort((a, b) => new Date(b.date) - new Date(a.date));
        let bal = transactions.reduce((sum, t) => t.type === 'Отримання' ? sum + t.amount : sum - t.amount, 0);
        ui.balance.innerText = bal.toLocaleString("uk-UA") + " ₴";

        ui.recentList.innerHTML = "";
        ui.historyList.innerHTML = "";

        transactions.forEach((t, index) => {
            const dateObj = new Date(t.date);
            const dateStr = `${('0'+dateObj.getDate()).slice(-2)}.${('0'+(dateObj.getMonth()+1)).slice(-2)}`;
            const html = `
                <li class="list-row">
                    <span class="date-sub">${dateStr}</span>
                    <span>${t.comment || '-'}</span>
                    <span class="amount ${t.type === 'Отримання' ? 'income' : 'expense'}">
                        ${t.amount.toLocaleString("uk-UA")} ₴
                    </span>
                    <button class="delete-btn" onclick="deleteItem('${t.id}')">✕</button>
                </li>
            `;
            if (index < 5) ui.recentList.insertAdjacentHTML("beforeend", html);
            ui.historyList.insertAdjacentHTML("beforeend", html);
        });
    }

    window.deleteItem = function(id) {
        transactions = transactions.filter(t => t.id !== id);
        saveState();
    };

    ui.btnSave.addEventListener("click", () => {
        let amount = parseFloat(ui.inputAmount.value.replace(',', '.'));
        if (!amount || amount <= 0) return;

        transactions.push({
            id: Date.now().toString(),
            date: ui.inputDate.value,
            type: ui.inputTypeIncome.checked ? 'Отримання' : 'Видача',
            comment: ui.inputComment.value.trim(),
            amount: amount
        });

        ui.inputAmount.value = "";
        ui.inputComment.value = "";
        saveState();
    });

    ui.btnClear.addEventListener("click", () => {
        if (confirm("Видалити всі дані?")) {
            transactions = [];
            saveState();
        }
    });

    ui.fileImport.addEventListener("change", (e) => {
        const file = e.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = (ev) => {
            const text = ev.target.result;
            const lines = text.split("\n");
            let imported = 0;
            
            lines.forEach(line => {
                if (!line.trim()) return;
                
                // Перевіряємо роздільник
                let cols = line.split(";");
                if (cols.length < 3) {
                    cols = line.split(",");
                }
                cols = cols.map(c => c.replace(/"/g, '').trim());
                
                if (cols.length < 3) return;

                // Парсинг дати (витягуємо саму дату без часу 00:00:00)
                let dateStr = cols[0].split(" ")[0];
                let dParts = dateStr.includes(".") ? dateStr.split(".") : dateStr.split("-");
                if (dParts.length !== 3) return;
                
                // Зводимо дату до формату YYYY-MM-DD для правильного сортування
                let isoDate = dateStr;
                if (dateStr.includes(".")) {
                    isoDate = `${dParts[2]}-${dParts[1]}-${dParts[0]}`;
                } else if (dParts[0].length === 2) {
                    isoDate = `${dParts[2]}-${dParts[1]}-${dParts[0]}`;
                }
                
                let rawAmount = parseFloat(cols[2].replace(',', '.').replace(/\s/g, ''));
                if (isNaN(rawAmount) || rawAmount === 0) return;

                let isIncome = cols[1].toLowerCase().includes("отримано");
                
                transactions.push({
                    id: Date.now().toString() + Math.random().toString(),
                    date: isoDate,
                    type: isIncome ? 'Отримання' : 'Видача',
                    amount: Math.abs(rawAmount),
                    comment: cols[3] ? cols[3].replace(';', '') : 'Імпорт'
                });
                imported++;
            });
            
            saveState();
            alert(`Імпортовано ${imported} записів!`);
            e.target.value = "";
            document.querySelector('[data-target="dashboard"]').click();
        };
        reader.readAsText(file);
    });

    updateUI();
});
