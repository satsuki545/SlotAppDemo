class MedalManager {
int _inserted = 0; // 投入
int _payout = 0; // 払い出し


void insertPerGame() { _inserted += 3; }
void payout(int medals) { _payout += medals; }


int get inserted => _inserted;
int get payoutTotal => _payout;
int get difference => _payout - _inserted;


void reset() { _inserted = 0; _payout = 0; }
}