# Verwende das offizielle, leichtgewichtige Nginx-Alpine-Image als Basis
FROM nginx:alpine

# Kopiere die index.html in das Standard-Web-Verzeichnis von Nginx
COPY index.html /usr/share/nginx/html/index.html

# Exponiere Port 80 für den Web-Traffic
EXPOSE 80

# Starte Nginx im Vordergrund
CMD ["nginx", "-g", "daemon off;"]
