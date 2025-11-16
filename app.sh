#!/bin/bash
# app.sh - Aplikasi Gaji Paruh Waktu

# -----------------------
# Warna dan konstanta
# -----------------------
RED=$'\e[31m'        # merah
GREEN=$'\e[32m'      # hijau
YELLOW=$'\e[33m'     # kuning
BLUE=$'\e[34m'       # biru
MAGENTA=$'\e[35m'    # magenta
CYAN=$'\e[36m'       # cyan
BOLD=$'\e[1m'        # tebal
RESET=$'\e[0m'       # reset warna

DATA_FILE="employees.csv"                # file penyimpanan
LINE="${CYAN}=========================================================${RESET}"

# -----------------------
# Util: format rupiah
# -----------------------
format_rupiah() {
  local num="$1"
  # kalau bukan angka (integer atau desimal) kembalikan apa adanya
  if ! [[ "$num" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
    printf "%s" "$num"
    return
  fi
  # simpan tanda minus bila ada, pisah bagian integer dan desimal
  local sign=""
  [[ "$num" == -* ]] && sign="-" && num="${num#-}"
  local int="${num%%.*}"
  local frac=""
  [[ "$num" == *.* ]] && frac=".${num#*.}"
  # sisipkan titik tiap 3 digit dari kanan (pakai rev + sed)
  int=$(printf "%s" "$int" | rev | sed -E 's/([0-9]{3})/\1./g' | rev)
  int="${int#.}"   # hilangkan titik di depan bila ada

  printf "%s%s%s" "$sign" "$int" "$frac"
}

# -----------------------
# Util: inisialisasi penyimpanan
# -----------------------
init_storage() {
  if [ ! -f "$DATA_FILE" ]; then
    printf "name|position|hours|rate|total|timestamp\n" > "$DATA_FILE"
  fi
}

# -----------------------
# Tampilan header
# -----------------------
print_header() {
  clear
  printf "%b\n" "$LINE"
  printf "%b\n" "${BLUE}${BOLD}                  APLIKASI GAJI PARUH WAKTU${RESET}"
  printf "%b\n" "${MAGENTA}${BOLD}       Cook Helper • Waitress • Barista • Dishwasher${RESET}"
  printf "%b\n" "$LINE"
  printf "\n"
}

# -----------------------
# Progress sederhana
# -----------------------
progress_bar() {
  printf "%b" "${GREEN}Menghitung"
  for i in $(seq 1 10); do
    printf "."
    sleep 0.08
  done
  printf "%b\n" "${RESET}"
}

# -----------------------
# Input: nama karyawan
# -----------------------
prompt_name() {
  printf "%b" "${CYAN}Nama karyawan : ${RESET}"
  read -r name
}

# -----------------------
# Input: posisi dengan loop validasi
# -----------------------
prompt_position() {
  while true; do
    printf "%b" "${CYAN}Posisi        : ${RESET}"
    read -r position
    pos_lc=$(printf "%s" "$position" | tr '[:upper:]' '[:lower:]')
    case "$pos_lc" in
      "cook helper"|"cook")
        rate=50000
        break
        ;;
      "waitress"|"waiter")
        rate=30000
        break
        ;;
      "barista")
        rate=40000
        break
        ;;
      "dishwasher"|"dw")
        rate=35000
        break
        ;;
      *)
        printf "%b\n" "${RED}Posisi tidak dikenal. Coba lagi.${RESET}"
        printf "%b\n" "${YELLOW}Pilihan: Cook Helper, Waitress, Barista, Dishwasher${RESET}"
        ;;
    esac
  done
}

# -----------------------
# Input: jam kerja (boleh desimal)
# -----------------------
prompt_hours() {
  while true; do
    printf "%b" "${CYAN}Jam kerja     : ${RESET}"
    read -r hours

    # validasi angka bulat (0–999)
    if [[ "$hours" =~ ^[0-9]+$ ]]; then
      break
    else
      printf "%b\n" "${YELLOW}Input jam harus angka bulat. Contoh: 40 atau 55${RESET}"
    fi
  done
}


# -----------------------
# Hitung gaji (mendukung desimal) menggunakan bc
# -----------------------
# hasil total disimpan di variabel total_pay
calculate_pay() {
  # jika jam kerja lebih dari 40, hitung lembur
  if [ "$hours" -gt 40 ]; then
    overtime=$((hours - 40))
    overtime_pay=$((overtime * rate * 2))
    regular_pay=$((40 * rate))
    total_pay=$((regular_pay + overtime_pay))
  else
    total_pay=$((hours * rate))
  fi
}

# -----------------------
# Cetak hasil ke layar
# -----------------------
print_result() {
  printf "\n"
  printf "%b\n" "$LINE"
  printf "%b\n" "${MAGENTA}${BOLD}           HASIL PERHITUNGAN GAJI PERMINGGU${RESET}"
  printf "%b\n" "$LINE"

  printf "%-15s : %s\n" "Nama" "$name"
  printf "%-15s : %s\n" "Posisi" "$position"
  printf "%-15s : %s jam\n" "Jam kerja" "$hours"
  printf "%-15s : Rp %s\n" "Rate" "$(format_rupiah "$rate")"
  printf "%-15s : Rp %s\n" "Total Gaji" "$(format_rupiah "$total_pay")"

  printf "%b\n" "$LINE"
}

# -----------------------
# Simpan record ke file
# -----------------------
save_record() {
  init_storage
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo "${name}|${position}|${hours}|${rate}|${total_pay}|${timestamp}" >> "$DATA_FILE"
}

# -----------------------
# Konfirmasi ulang apakah mau hitung lagi
# -----------------------
confirm_retry() {
  while true; do
    printf "%b" "${CYAN}Hitung karyawan lain? (y/n): ${RESET}"
    read -r answer
    case "$answer" in
      [Yy]*) return 0 ;;   # lanjut
      [Nn]*) return 1 ;;   # keluar
      *) printf "%b\n" "${RED}Jawab y atau n.${RESET}" ;;
    esac
  done
}

# -----------------------
# Main loop
# -----------------------
init_storage

while true; do
  print_header
  prompt_name
  prompt_position
  prompt_hours

  printf "\n"
  progress_bar

  calculate_pay
  print_result
  save_record

  # tampil info penyimpanan singkat
  printf "%b\n" "${GREEN}Data tersimpan di ${DATA_FILE}${RESET}"

  # tanya mau ulang
  if confirm_retry; then
    continue
  else
    printf "%b\n" "${BLUE}${BOLD}Terima kasih. Sampai jumpa.${RESET}"
    break
  fi
done

exit 0
