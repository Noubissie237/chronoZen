# ⏳ ChronoZen

ChronoZen est une application mobile de gestion des tâches quotidiennes avec minuterie intégrée. Elle vous aide à mieux organiser vos journées, suivre votre productivité et maintenir votre concentration grâce à un système simple mais puissant de suivi du temps.

---

## 📱 Fonctionnalités principales

- ✅ Création de tâches avec durée personnalisée
- ⏱️ Minuteur intégré dans chaque tâche, avec :
  - décompte visuel circulaire
  - alerte sonore à la fin
  - option pause / reprendre / arrêter
- 🗓️ Tâches de 3 types :
  - **Persistantes** : reviennent tous les jours
  - **Semi-persistantes** : valables sur une plage de dates
  - **Non-persistantes** : valables une seule fois
- 🔔 Notifications locales avec son à la fin d’une tâche
- 🧘 Résumé quotidien :
  - Temps total prévu
  - Temps libre restant (hors heures de sommeil)
- 📊 Statistiques hebdomadaires :
  - Graphique de productivité
  - Suivi du temps accompli
  - Taux de complétion
- 🕛 Réinitialisation automatique à minuit

---

## ⚙️ Tech Stack

- **Flutter** + **Provider** (state management)
- **Sqflite** pour la base locale
- **Android Alarm Manager Plus** pour la réinitialisation à minuit
- **Flutter Local Notifications** pour les alertes
- **fl_chart** pour les statistiques graphiques

---

## 🧪 Lancer le projet en local

1. **Clone ce repo :**
```bash
git clone https://github.com/Noubissie237/chronoZen.git
cd chronoZen
````

2. **Installe les dépendances :**

```bash
flutter pub get
```

3. **Lance sur un appareil Android (physique ou émulateur) :**

```bash
flutter run
```

⚠️ Les notifications fonctionnent à 100 % sur **Android 13+** si :

* l'autorisation `POST_NOTIFICATIONS` est acceptée,
* le téléphone n’est pas en mode silencieux.

---

## 📁 Structure du projet

```
lib/
├── models/           → Modèle de tâche
├── services/         → Provider, base SQLite
├── screens/          → Pages principales (Home, Formulaire, Statistiques)
├── widgets/          → UI réutilisables (TaskCard, Timer)
├── utils/            → Notification helper, time formatting
└── main.dart         → Entrée principale
```

---

## 🚀 Prochaines évolutions

* 🔄 Synchronisation avec Google Agenda
* 🌙 Mode Pomodoro
* ☁️ Sauvegarde cloud
* 🧠 Intelligence adaptative (suggestion de planification)

---

## 👨‍💻 Auteur

Développé avec ❤️ par [Noubissie Wilfried](https://github.com/Noubissie237)

---

## 📄 Licence

MIT License – Libre d’utilisation, de modification et de distribution.


