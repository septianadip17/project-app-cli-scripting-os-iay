#!/usr/bin/env bash

# app.sh - Perbaikan: warna tampil benar pada ./app.sh

# Warna (gunakan $'...' agar berisi escape nyata)
RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
BLUE=$'\e[34m'
MAGENTA=$'\e[35m'
CYAN=$'\e[36m'
BOLD=$'\e[1m'
RESET=$'\e[0m'

line="${CYAN}==============================================${RESET}"

# fungsi progress sederhana
progress_bar() {
  printf "%b" "${GREEN}Menghitung"
  for i in $(seq 1 10); do
    printf "."
    sleep 0.06
  done
  printf "%b\n" "${RESET}"
}

# header
clear
printf "%b\n" "$line"
printf "%b\n" "${BLUE}${BOLD}        APLIKASI GAJI PARUH WAKTU${RESET}"
printf "%b\n" "$line"
printf "\n"

# input menggunakan printf lalu read
printf "%b" "${YELLOW}Masukkan Data Karyawan${RESET}\n"
printf "%b" "$line\n"

printf "%b" "${CYAN}Nama karyawan: ${RESET}"
read -r name

printf "%b" "${CYAN}Posisi (Cook Helper / Waitress / Barista / Dishwasher): ${RESET}"
read -r position

printf "%b" "${CYAN}Jam kerja: ${RESET}"
read -r hours

printf "\n"
progress_bar

# Hitung rate (case-insensitive)
pos_lc=$(printf "%s" "$position" | tr '[:upper:]' '[:lower:]')
case "$pos_lc" in
  "cook helper"|"cook")
    rate=50000
    ;;
  "waitress"|"waiter")
    rate=30000
    ;;
  "barista")
    rate=40000
    ;;
  "dishwasher"|"dw")
    rate=35000
    ;;
  *)
    printf "%b\n" "${RED}Posisi tidak dikenal.${RESET}"
    exit 1
    ;;
esac

# Hitung gaji dengan overtime >40 jam
if ! [[ "$hours" =~ ^[0-9]+$ ]]; then
  printf "%b\n" "${YELLOW}Input jam harus angka.${RESET}"
  exit 1
fi

if [ "$hours" -gt 40 ]; then
  overtime=$((hours - 40))
  overtime_pay=$((overtime * rate * 2))
  regular_pay=$((40 * rate))
  total_pay=$((regular_pay + overtime_pay))
else
  total_pay=$((hours * rate))
fi

# Output rapi menggunakan printf
printf "\n"
printf "%b\n" "$line"
printf "%b\n" "${MAGENTA}${BOLD}           HASIL PERHITUNGAN GAJI${RESET}"
printf "%b\n" "$line"

printf "%-15s : %s\n" "Nama" "$name"
printf "%-15s : %s\n" "Posisi" "$position"
printf "%-15s : %s jam\n" "Jam kerja" "$hours"
printf "%-15s : Rp %s\n" "Rate" "$rate"
printf "%-15s : Rp %s\n" "Total Gaji" "$total_pay"

printf "%b\n" "$line"
printf "%b\n" "${BLUE}${BOLD}Terima kasih telah menggunakan aplikasi ini.${RESET}"
