#!/bin/bash
# Скрипт для пакетного даунскейла видеофайлов и уменьшения битрейта (ffmpeg)
# Использование: ./downscale_n_shrink.sh [имя файла со списком исходных файлов]
# Список должен быть с переносами в формате Windows (CR+LF)

# Переменные
BASE_PATH="/path/to/source/files"
PREFIX="[1440p]" # добавляемый префикс для новых файлов
RES_WIDTH=2560 # целевое разрешение (ширина)
CRF=18 # целевое качество видеофайла
GR_COL='\e[1;32m'
RD_COL='\e[1;31m'
YE_COL='\e[1;33m'
NO_COL='\e[0m'

# Проверка числа аргументов
if [ $# = 0 ] || [ $# \> 1 ]; then
	echo -e "${RD_COL}Необходимо дать список файлов для конвертации!${NO_COL}"
	exit 1
fi

# Отсчёт времени на задачу
SECONDS=0

# Отключить перенос строк (чтобы строка прогресса ffmpeg не дублировалась)
setterm -linewrap off

# Цикл перебора списка файлов
FILES_TOTAL=0
FILES_PROCESSED=0
IFS=$'\r\n'
for FILE in $(cat $1); do
	FILES_TOTAL=$(( $FILES_TOTAL + 1 ))
	# Замена слеша на POSIX-стандарт
	OLD_NAME=${FILE//\\/$'/'}
	FULL_OLD_NAME="$BASE_PATH/$OLD_NAME"
	
	# Проверка на существование исходного файла
	if [ ! -f $FULL_OLD_NAME ]; then
		echo -e "${RD_COL}Файл №$FILES_TOTAL: исходный файл не найден!\n\"$OLD_NAME\"${NO_COL}"
		continue
	fi
	
	NEW_NAME=${OLD_NAME%.*}
	EXTENSION=${OLD_NAME##*.}
	FULL_NEW_NAME="$BASE_PATH/$NEW_NAME $PREFIX.$EXTENSION"
	
	# Проверка на существование конечного файла
	if [ -f $FULL_NEW_NAME ]; then
		echo -e "${RD_COL}Файл №$FILES_TOTAL: конечный файл уже существует! Пропускаем...\n\"$OLD_NAME\"${NO_COL}"
		continue
	fi
	
	FILES_PROCESSED=$(( $FILES_PROCESSED + 1 ))
	echo -e "${GR_COL}Обрабатываем файл №$FILES_TOTAL:\n\"$OLD_NAME\"${NO_COL}"
	ffmpeg -i "$FULL_OLD_NAME" -vf scale=$RES_WIDTH:-2 -crf $CRF -c:a copy -hide_banner "$FULL_NEW_NAME"
	# rm "$FULL_OLD_NAME" # удалить исходный файл
done

# Включить обратно перенос строк
setterm -linewrap on

# Вывести отчёт
DURATION=$SECONDS
echo -e "\n${YE_COL}Задание выполнено. Обработано $FILES_PROCESSED из $FILES_TOTAL файлов.\n$(($DURATION / 3600)):$((($DURATION % 3600) / 60)):$(($DURATION % 60)) затрачено.${NO_COL}"