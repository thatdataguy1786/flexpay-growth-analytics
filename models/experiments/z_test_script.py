import math
from statsmodels.stats.proportion import proportions_ztest

# Input data (update with your actual values)
template_a_sent = 506
template_a_paid = 324

template_b_sent = 512
template_b_paid = 319

# Values for the test
successes = [template_a_paid, template_b_paid]
samples = [template_a_sent, template_b_sent]

# Run 2-proportion Z-test
z_stat, p_value = proportions_ztest(successes, samples)

# Print results
print(f"Z-Statistic: {z_stat:.3f}")
print(f"P-Value: {p_value:.4f}")

# Interpretation
if p_value < 0.05:
    print("✅ Statistically significant difference!")
else:
    print("❌ No significant difference.")
