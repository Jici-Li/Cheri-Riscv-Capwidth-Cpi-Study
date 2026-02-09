import csv
import matplotlib.pyplot as plt

rows = []
with open("results.csv") as f:
    r = csv.DictReader(f)
    for row in r:
        if row["tag"] == "A4":
            rows.append(row)

groups = {}
for row in rows:
    key = (row["tag"], int(row["width"]))
    groups.setdefault(key, []).append((int(row["work_kb"]), float(row["cpi"])))

for (tag, width), pts in groups.items():
    pts.sort()
    xs = [x for x, _ in pts]
    ys = [y for _, y in pts]
    plt.plot(xs, ys, marker="o", label=f"{tag}, bit Baseline={8*width} bit")

plt.xlabel("Working set (KB)")
plt.ylabel("CPI")
plt.title("gem5 sweep")
plt.grid(True)
plt.legend()
plt.show()
