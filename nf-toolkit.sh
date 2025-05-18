#!/bin/bash

# Configuración de colores (256 colores)
titulo='\e[1;38;5;45m'       # Azul claro
subtitulo='\e[1;38;5;51m'    # Cian brillante
error='\e[1;38;5;196m'       # Rojo intenso
exito='\e[1;38;5;46m'        # Verde neón
advertencia='\e[1;38;5;226m' # Amarillo brillante
input_color='\e[1;38;5;51m'  # Cian
reset='\e[0m'                 # Reset
separador='\e[1;38;5;27m'    # Azul medio
banner='\e[1;38;5;33m'       # Azul oscuro
menu_color='\e[1;38;5;75m'   # Azul intermedio
destacado='\e[1;38;5;208m'   # Naranja

# ASCII Art mejorado
show_banner() {
  clear
  echo -e "${banner}"
  echo -e " ███╗   ██╗███████╗    ████████╗ ██████╗  ██████╗ ██╗     ██╗  ██╗██╗████████╗"
  echo -e " ████╗  ██║██╔════╝    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██║ ██╔╝██║╚══██╔══╝"
  echo -e " ██╔██╗ ██║█████╗         ██║   ██║   ██║██║   ██║██║     █████╔╝ ██║   ██║   "
  echo -e " ██║╚██╗██║██╔══╝         ██║   ██║   ██║██║   ██║██║     ██╔═██╗ ██║   ██║   "
  echo -e " ██║ ╚████║██║            ██║   ╚██████╔╝╚██████╔╝███████╗██║  ██╗██║   ██║   "
  echo -e " ╚═╝  ╚═══╝╚═╝            ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝   "
  echo -e "${reset}"
  echo -e "${titulo}          Herramientas profesionales para análisis web${reset}"
  echo -e "${separador}════════════════════════════════════════════════════════════════${reset}\n"
}

# Función para mostrar el menú principal
menu_principal() {
  echo -e "${menu_color}"
  echo -e " 🗂  MENÚ PRINCIPAL"
  echo -e "${separador}════════════════════════════════════════════════════════════════${reset}"
  echo -e " ${destacado}[1]${menu_color}  Búsqueda de Subdominios       ${destacado}[4]${menu_color}  Escáner de Puertos"
  echo -e " ${destacado}[2]${menu_color}  Generador de Payloads HTTP    ${destacado}[5]${menu_color}  Análisis de Headers"
  echo -e " ${destacado}[3]${menu_color}  Verificador de DNS           ${destacado}[6]${menu_color}  Detección de Tecnologías"
  echo -e "${separador}════════════════════════════════════════════════════════════════${reset}"
  echo -e " ${destacado}[0]  Salir${reset}"
  echo -e "${separador}════════════════════════════════════════════════════════════════${reset}"
}

# Validación de dominio mejorada
validar_dominio() {
  [[ "$1" =~ ^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$ ]] && return 0 || return 1
}

# Identificar proveedor por IP
identify_provider() {
  local ip="$1"
  local prov
  prov=$(timeout 2 whois "$ip" 2>/dev/null | grep -Ei 'OrgName|NetName|descr' | head -n1 | cut -d':' -f2- | sed 's/^ *//;s/ *$//')
  [[ -z "$prov" ]] && echo "Desconocido" || echo "$prov"
}

# Búsqueda de Subdominios
subdomain_finder() {
  clear
  echo -e "${titulo}"
  echo -e " ███████╗██╗   ██╗██████╗ ██████╗  ██████╗ ███╗   ███╗██╗███╗   ██╗███████╗"
  echo -e " ██╔════╝██║   ██║██╔══██╗██╔══██╗██╔═══██╗████╗ ████║██║████╗  ██║██╔════╝"
  echo -e " ███████╗██║   ██║██║  ██║██║  ██║██║   ██║██╔████╔██║██║██╔██╗ ██║█████╗  "
  echo -e " ╚════██║██║   ██║██║  ██║██║  ██║██║   ██║██║╚██╔╝██║██║██║╚██╗██║██╔══╝  "
  echo -e " ███████║╚██████╔╝██████╔╝██████╔╝╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║███████╗"
  echo -e " ╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝"
  echo -e "${reset}${subtitulo}            Encuentra subdominios activos e inactivos${reset}"
  echo -e "${separador}════════════════════════════════════════════════════════════════${reset}"
  
  while true; do
    echo -e "${advertencia}╭╼╼╼╼╼╼╼╼╼╼╼╼╼╼╼[Ejemplo: google.com]${reset}"
    echo -ne "${input_color}╰╼> ${reset}"
    read dominio
    validar_dominio "$dominio" && break
    echo -e "${error}[!] Dominio inválido, intente nuevamente${reset}"
  done

  echo -e "\n${subtitulo}[+] Buscando subdominios de ${reset}${destacado}$dominio${reset}${subtitulo}...\n${reset}"
  
  echo -ne "${separador}[${subtitulo}                    ${separador}] 0%${reset}\r"
  raw=$(timeout 15 curl -fLs "https://crt.sh/?q=%25.${dominio}&output=json")
  [ $? -ne 0 ] && echo -e "\n${error}[×] Error al obtener datos de crt.sh${reset}" && sleep 2 && return
  echo -ne "${separador}[${subtitulo}████████████████████${separador}] 100%${reset}\n"

  subdominios=()
  if jq -e . >/dev/null 2>&1 <<<"$raw"; then
    mapfile -t subdominios < <(jq -r '.[].name_value' <<<"$raw" | sort -u | grep -P "(?i)${dominio}$")
  else
    mapfile -t subdominios < <(grep -oP "(?<=<TD>)[A-Za-z0-9._-]+\.${dominio}(?=</TD>)" <<<"$raw" | sort -u)
  fi

  [ ${#subdominios[@]} -eq 0 ] && echo -e "\n${error}[×] No se encontraron subdominios válidos.${reset}" && sleep 2 && return

  activos=()
  inactivos=()
  total=${#subdominios[@]}
  contador=0

  for sub in "${subdominios[@]}"; do
    ((contador++))
    echo -ne "${subtitulo}Analizando ($contador/$total): ${sub:0:30}...${reset}\r"
    
    ip=$(timeout 2 dig +short "$sub" | head -n1)
    codigo=$(timeout 5 curl -o /dev/null -s -I -w "%{http_code}" "http://$sub")
    provider=$(identify_provider "$ip")
    
    if [[ -n "$ip" && "$codigo" =~ ^[23] ]]; then
      activos+=("$sub|$ip|$codigo|$provider")
    else
      inactivos+=("$sub|${ip:-No resuelta}|${codigo:-Timeout}|$provider")
    fi
  done
  echo -e "\n"

  # Mostrar resultados activos
  echo -e "\n${exito}=== Subdominios ACTIVOS (${#activos[@]}) ===${reset}\n"
  for entry in "${activos[@]}"; do
    IFS='|' read -r sub ip codigo provider <<< "$entry"
    echo -e "${separador}──────────────────────────────────────────────${reset}"
    echo -e "${destacado}Dominio:   ${reset}${exito}$sub${reset}"
    echo -e "${destacado}IP:        ${reset}$ip"
    echo -e "${destacado}Estado:    ${reset}${exito}ACTIVO (${codigo})${reset}"
    echo -e "${destacado}Proveedor: ${reset}$provider"
  done
  [ ${#activos[@]} -gt 0 ] && echo -e "${separador}──────────────────────────────────────────────${reset}"

  # Mostrar resultados inactivos si se solicita
  echo -e "\n${advertencia}Presiona Enter para continuar o escribe '55' para ver inactivos...${reset}"
  read opcion
  if [[ "$opcion" == "55" ]]; then
    echo -e "\n${error}=== Subdominios INACTIVOS (${#inactivos[@]}) ===${reset}\n"
    for entry in "${inactivos[@]}"; do
      IFS='|' read -r sub ip codigo provider <<< "$entry"
      echo -e "${separador}──────────────────────────────────────────────${reset}"
      echo -e "${destacado}Dominio:   ${reset}${error}$sub${reset}"
      echo -e "${destacado}IP:        ${reset}$ip"
      echo -e "${destacado}Estado:    ${reset}${error}INACTIVO (${codigo})${reset}"
      echo -e "${destacado}Proveedor: ${reset}$provider"
    done
    [ ${#inactivos[@]} -gt 0 ] && echo -e "${separador}──────────────────────────────────────────────${reset}"
  fi
  
  echo -e "\n${advertencia}Presiona Enter para continuar...${reset}"
  read
}

# Generador de Payloads HTTP
payload_generator() {
  clear
  echo -e "${titulo}"
  echo -e " ███╗   ███╗██╗   ██╗██╗  ████████╗██╗  ██████╗  █████╗ ██╗   ██╗██╗      ██████╗  █████╗ ██████╗ "
  echo -e " ████╗ ████║██║   ██║██║  ╚══██╔══╝██║  ██╔══██╗██╔══██╗╚██╗ ██╔╝██║     ██╔═══██╗██╔══██╗██╔══██╗"
  echo -e " ██╔████╔██║██║   ██║██║     ██║   ██║  ██████╔╝███████║ ╚████╔╝ ██║     ██║   ██║██║  ██║██║  ██║"
  echo -e " ██║╚██╔╝██║██║   ██║██║     ██║   ██║  ██╔═══╝ ██╔══██║  ╚██╔╝  ██║     ██║   ██║██║  ██║██║  ██║"
  echo -e " ██║ ╚═╝ ██║╚██████╔╝███████╗██║   ██║  ██║     ██║  ██║   ██║   ███████╗╚██████╔╝╚█████╔╝██████╔╝"
  echo -e " ╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝  ╚═╝     ╚═╝  ╚═╝   ╚═╝   ╚══════╝ ╚═════╝  ╚════╝ ╚═════╝ "
  echo -e "${reset}${subtitulo}           Genera payloads HTTP para pruebas de seguridad${reset}"
  echo -e "${separador}════════════════════════════════════════════════════════════════${reset}"
  
  while true; do
    echo -ne "${advertencia}Host (ejemplo: example.com): ${reset}"
    read host
    validar_dominio "$host" && break
    echo -e "${error}[!] Dominio inválido, intente nuevamente${reset}"
  done

  echo -e "\n${exito}=== Payloads generados para ${host} ===${reset}\n"
  
  # Payload 1: CRLF Injection
  echo -e "${destacado}1) CRLF Injection:${reset}"
  printf "GET / HTTP/1.1\r\nHost: %s\r\nX-Injected-Header: true\r\n\r\n" "$host" | sed 's/\r/[crlf]/g'
  
  # Payload 2: HTTP Smuggling
  echo -e "\n${destacado}2) HTTP Smuggling (CL.TE):${reset}"
  printf "POST / HTTP/1.1\r\nHost: %s\r\nContent-Length: 6\r\nTransfer-Encoding: chunked\r\n\r\n0\r\n\r\n" "$host" | sed 's/\r/[crlf]/g'
  
  # Payload 3: Basic Auth
  echo -e "\n${destacado}3) Autenticación Básica:${reset}"
  printf "GET /private HTTP/1.1\r\nHost: %s\r\nAuthorization: Basic YWRtaW46cGFzc3dvcmQ=\r\n\r\n" "$host" | sed 's/\r/[crlf]/g'
  
  echo -e "\n${advertencia}Presiona Enter para continuar...${reset}"
  read
}

# Verificación de DNS
dns_check() {
  clear
  echo -e "${titulo}"
  echo -e " ██████╗ ███╗   ██╗███████╗"
  echo -e " ██╔══██╗████╗  ██║██╔════╝"
  echo -e " ██║  ██║██╔██╗ ██║███████╗"
  echo -e " ██║  ██║██║╚██╗██║╚════██║"
  echo -e " ██████╔╝██║ ╚████║███████║"
  echo -e " ╚═════╝ ╚═╝  ╚═══╝╚══════╝"
  echo -e "${reset}${subtitulo}       Verificación de registros DNS${reset}"
  echo -e "${separador}════════════════════════════════════════════════════════════════${reset}"
  
  while true; do
    echo -ne "${advertencia}Introduce el dominio a verificar: ${reset}"
    read dominio
    validar_dominio "$dominio" && break
    echo -e "${error}[!] Dominio inválido, intente nuevamente${reset}"
  done

  echo -e "\n${exito}=== Registros DNS para ${dominio} ===${reset}\n"
  
  dns_records=("A" "AAAA" "MX" "TXT" "NS" "CNAME" "SOA")
  
  for record in "${dns_records[@]}"; do
    echo -e "${destacado}${record} Records:${reset}"
    resultado=$(dig +short $record "$dominio" | sed 's/^/  /')
    [ -z "$resultado" ] && echo -e "  ${error}No encontrado${reset}" || echo -e "  ${exito}$resultado${reset}"
    echo
  done
  
  echo -e "${advertencia}Presiona Enter para continuar...${reset}"
  read
}

# Escáner de Puertos
port_scanner() {
  clear
  echo -e "${titulo}"
  echo -e " ███████╗ ██████╗ █████╗ ███╗   ██╗███████╗██████╗ "
  echo -e " ██╔════╝██╔════╝██╔══██╗████╗  ██║██╔════╝██╔══██╗"
  echo -e " ███████╗██║     ███████║██╔██╗ ██║█████╗  ██████╔╝"
  echo -e " ╚════██║██║     ██╔══██║██║╚██╗██║██╔══╝  ██╔══██╗"
  echo -e " ███████║╚██████╗██║  ██║██║ ╚████║███████╗██║  ██║"
  echo -e " ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝"
  echo -e "${reset}${subtitulo}          Escaneo avanzado de puertos${reset}"
  echo -e "${separador}════════════════════════════════════════════════════════════════${reset}"
  
  while true; do
    echo -ne "${advertencia}Introduce la dirección IP o dominio: ${reset}"
    read objetivo
    if [[ "$objetivo" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || validar_dominio "$objetivo"; then
      break
    fi
    echo -e "${error}[!] Entrada inválida${reset}"
  done

  puertos=(21 22 80 443 8080 3306 5432 8000 3389)
  
  echo -e "\n${exito}Escaneando ${objetivo}...${reset}\n"
  
  for port in "${puertos[@]}"; do
    timeout 1 bash -c "echo >/dev/tcp/$objetivo/$port" 2>/dev/null
    if [ $? -eq 0 ]; then
      servicio=$(grep "^$port/" /etc/services | awk '{print $1}' | head -1)
      echo -e " ${exito}[✔] Puerto ${port} abierto - ${servicio}${reset}"
    else
      echo -e " ${error}[✘] Puerto ${port} cerrado${reset}"
    fi
  done
  
  echo -e "\n${advertencia}Presiona Enter para continuar...${reset}"
  read
}

# Análisis de Headers HTTP
header_analysis() {
  clear
  echo -e "${titulo}"
  echo -e " █████╗ ███╗   ██╗██████╗  █████╗ ██╗  ██╗███████╗███████╗"
  echo -e "██╔══██╗████╗  ██║██╔══██╗██╔══██╗██║  ██║██╔════╝██╔════╝"
  echo -e "███████║██╔██╗ ██║██║  ██║███████║███████║█████╗  ███████╗"
  echo -e "██╔══██║██║╚██╗██║██║  ██║██╔══██║██╔══██║██╔══╝  ╚════██║"
  echo -e "██║  ██║██║ ╚████║██████╔╝██║  ██║██║  ██║███████╗███████║"
  echo -e "╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝"
  echo -e "${reset}${subtitulo}         Análisis de cabeceras HTTP${reset}"
  echo -e "${separador}════════════════════════════════════════════════════════════════${reset}"
  
  while true; do
    echo -ne "${advertencia}Introduce la URL a analizar (ej: https://example.com): ${reset}"
    read url
    [[ "$url" =~ ^https?:// ]] && break
    echo -e "${error}[!] URL debe comenzar con http:// o https://${reset}"
  done

  echo -e "\n${exito}=== Resultados del análisis ===${reset}\n"
  
  headers=$(curl -sI -L "$url")
  echo -e "${destacado}Cabeceras HTTP:${reset}"
  echo "$headers" | sed 's/^/  /'
  
  security_headers=(
    "Strict-Transport-Security"
    "Content-Security-Policy"
    "X-Content-Type-Options"
    "X-Frame-Options"
    "X-XSS-Protection"
    "Referrer-Policy"
    "Feature-Policy"
    "Permissions-Policy"
  )
  
  echo -e "\n${destacado}Cabeceras de Seguridad:${reset}"
  for header in "${security_headers[@]}"; do
    result=$(echo "$headers" | grep -i "^$header:" || echo "No presente")
    color=$([ "$result" == "No presente" ] && echo "$error" || echo "$exito")
    echo -e "  ${color}${result}${reset}"
  done
  
  echo -e "\n${advertencia}Presiona Enter para continuar...${reset}"
  read
}

# Detección de Tecnologías
tech_detection() {
  clear
  echo -e "${titulo}"
  echo -e "██████╗ ███████╗████████╗████████╗██╗  ██╗██╗"
  echo -e "██╔══██╗██╔════╝╚══██╔══╝╚══██╔══╝██║  ██║██║"
  echo -e "██║  ██║█████╗     ██║      ██║   ███████║██║"
  echo -e "██║  ██║██╔══╝     ██║      ██║   ██╔══██║██║"
  echo -e "██████╔╝███████╗   ██║      ██║   ██║  ██║██║"
  echo -e "╚═════╝ ╚══════╝   ╚═╝      ╚═╝   ╚═╝  ╚═╝╚═╝"
  echo -e "${reset}${subtitulo}       Detección de tecnologías web${reset}"
  echo -e "${separador}════════════════════════════════════════════════════════════════${reset}"
  
  while true; do
    echo -ne "${advertencia}Introduce la URL a analizar (ej: https://example.com): ${reset}"
    read url
    [[ "$url" =~ ^https?:// ]] && break
    echo -e "${error}[!] URL debe comenzar con http:// o https://${reset}"
  done

  echo -e "\n${exito}=== Tecnologías detectadas ===${reset}\n"
  
  response=$(curl -sL "$url")
  headers=$(curl -sI -L "$url")
  
  # Detectar tecnologías
  detected=()
  
  # Servidor Web
  server=$(grep -i 'Server:' <<< "$headers" | head -1 | cut -d':' -f2- | sed 's/^ //')
  [ -n "$server" ] && detected+=("Servidor Web: ${server}")
  
  # Lenguajes
  [[ "$response" =~ PHP ]] && detected+=("PHP")
  [[ "$response" =~ \.js ]] && detected+=("JavaScript")
  [[ "$response" =~ \.asp ]] && detected+=("ASP")
  
  # Frameworks
  [[ "$response" =~ wp-content ]] && detected+=("WordPress")
  [[ "$response" =~ laravel ]] && detected+=("Laravel")
  [[ "$response" =~ react ]] && detected+=("React")
  [[ "$response" =~ bootstrap ]] && detected+=("Bootstrap")
  
  # Base de datos
  [[ "$response" =~ mysql ]] && detected+=("MySQL")
  [[ "$response" =~ postgresql ]] && detected+=("PostgreSQL")
  
  if [ ${#detected[@]} -gt 0 ]; then
    for tech in "${detected[@]}"; do
      echo -e "  ${exito}✔${reset} ${tech}"
    done
  else
    echo -e "  ${error}No se detectaron tecnologías${reset}"
  fi
  
  echo -e "\n${advertencia}Presiona Enter para continuar...${reset}"
  read
}

# Verificar dependencias
verificar_dependencias() {
  local faltantes=()
  local dependencias=(jq dig curl)
  
  for cmd in "${dependencias[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      faltantes+=("$cmd")
    fi
  done

  if [ ${#faltantes[@]} -gt 0 ]; then
    echo -e "${error}[×] Faltan dependencias esenciales:${reset}"
    for cmd in "${faltantes[@]}"; do
      case $cmd in
        jq)    echo " - jq: sudo apt-get install jq";;
        dig)   echo " - dnsutils: sudo apt-get install dnsutils";;
        curl)  echo " - curl: sudo apt-get install curl";;
      esac
    done
    exit 1
  fi
}

# Menú principal
menu() {
  while true; do
    show_banner
    menu_principal
    echo -ne "\n${input_color}➤ Selecciona una opción: ${reset}"
    read opc
    case $opc in
      1) subdomain_finder ;;
      2) payload_generator ;;
      3) dns_check ;;
      4) port_scanner ;;
      5) header_analysis ;;
      6) tech_detection ;;
      0) exit 0 ;;
      *)
        echo -e "\n${error}[!] Opción inválida. Intente nuevamente${reset}"
        sleep 1
        ;;
    esac
    # Limpiar buffer de entrada
    while read -r -t 0; do read -r; done
  done
}

# Inicio del script
verificar_dependencias
menu
