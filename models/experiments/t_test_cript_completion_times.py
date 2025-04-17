# ## 🧪 T-Test – Invoice Completion Time by Template

# **Objective**:  
# Assess whether Template B reduces the time it takes to complete and send an invoice compared to Template A.

# **Metric Tracked**:  
# - Invoice completion time (in minutes)

# **Statistical Test Used**:  
# ✅ Independent T-Test  
# (`scipy.stats.ttest_ind` in Python)

# **Results**:
# - T-Statistic: -1.085
# - P-Value: 0.2782 → ❌ Not statistically significant

# **Interpretation**:  
# There is no statistically significant difference in completion time between the two invoice templates. We cannot claim Template B is faster.

# **Recommendation**:
# - Explore qualitative feedback to understand usability
# - Monitor behavior across different user segments

from scipy import stats
import pandas as pd

# Load the data
df = pd.read_csv('/Users/kushrajbhatia/Documents/Personal Docs/Courses/SQL/flexpay-growth-analytics/models/experiments/completion_times.csv')

# Separate groups
group_a = df[df['invoice_template'] == 'classic']['completion_days']
group_b = df[df['invoice_template'] == 'modern']['completion_days']

# Run t-test
t_stat, p_value = stats.ttest_ind(group_a, group_b, equal_var=False)

# Print results
print(f"T-Statistic: {t_stat:.3f}")
print(f"P-Value: {p_value:.4f}")

if p_value < 0.05:
    print("✅ Statistically significant difference in average completion time.")
else:
    print("❌ No statistically significant difference.")
