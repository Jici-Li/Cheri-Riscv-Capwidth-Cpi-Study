import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("cpi_sweep.csv")

df["mem_gap"] = pd.to_numeric(df["mem_gap"])
df["comp_en"] = pd.to_numeric(df["comp_en"])
df["cpi"] = pd.to_numeric(df["cpi"])

df = df[df["mem_gap"] <= 16]

base = df[df["comp_en"] == 0].sort_values("mem_gap")
comp = df[df["comp_en"] == 1].sort_values("mem_gap")

plt.plot(base["mem_gap"], base["cpi"], marker='o', label="Uncompressed")
plt.plot(comp["mem_gap"], comp["cpi"], marker='s', label="Compressed")

plt.xlabel("Instructions per Memory Op")
plt.ylabel("CPI")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()
