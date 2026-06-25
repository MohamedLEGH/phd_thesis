import numpy as np
import matplotlib.pyplot as plt

# Génération des données
np.random.seed(0)

# Classe 0 : points centrés autour de (2, 2)
class_0 = np.random.randn(100, 2) + np.array([2, 2])

# Classe 1 : points centrés autour de (6, 6)
class_1 = np.random.randn(100, 2) + np.array([6, 6])

# Création de la figure
plt.figure(figsize=(6, 6))
plt.scatter(class_0[:, 0], class_0[:, 1], c='blue', label='Classe 0')
plt.scatter(class_1[:, 0], class_1[:, 1], c='red', label='Classe 1')

# Mise en forme
plt.title("Binary classification")
plt.xlabel("Feature 1")
plt.ylabel("Feature 2")
plt.legend()
plt.grid(True)
plt.axis('equal')

# Affichage
plt.show()
