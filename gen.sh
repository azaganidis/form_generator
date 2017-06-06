command -v dialog >/dev/null 2>&1 || { echo >&2 "no dialog. Aborting"; }
myname=$(cat config/myname)
sname1=$(cat config/sname1)
sname2=$(cat config/sname2)
NN1=$(cat config/current_state)
NN2=$(cat config/do_next)
studentID=$(cat config/sID)
DATE="not_set"
PROPOSED_DATE="not_set"
while [ -z "$GEN" ]
do
CHANGE_WHAT=$(dialog --menu "What to change" 30 40 20 1 "Current state " 2 "Actions to take" meeting_date "$DATE" n_meeting_date "$PROPOSED_DATE" sign "Change signature" ssign1 "Change supervisor signature" generate "Generate docx" name "$myname" sID "$studentID" supervisor1 "$sname1" supervisor2 "$sname2" progr "Programme" --output-fd 1)
case $CHANGE_WHAT in
	1)
		NN1=$(dialog --editbox config/current_state 30 80 --output-fd 1)
		echo $NN1>config/current_state ;;
	2)
		NN2=$(dialog --editbox config/do_next 30 80 --output-fd 1)
		echo $NN2>config/do_next ;;
	meeting_date) 
		DATE=$(date -d $(dialog --calendar "Meeting date" 3 39 --output-fd 1 | awk -F/ '{print $2"/"$1"/"$3}') +"%Y-%m-%d") ;;
	n_meeting_date) 
		PROPOSED_DATE=$(date -d $(dialog --calendar "Meeting date" 3 39 --output-fd 1 | awk -F/ '{print $2"/"$1"/"$3}') +"%Y-%m-%d") ;;
	name)
		myname=$(dialog --inputbox "Enter your name:" 8 40 --output-fd 1) 
		echo $myname > config/myname ;;
	supervisor1)
		sname1=$(dialog --inputbox "Enter 1st supervisor's name:" 8 40 --output-fd 1) 
		echo $sname1>config/sname1 ;;
	supervisor2)
		sname2=$(dialog --inputbox "Enter 2nd supervisor's name:" 8 40 --output-fd 1) 
		echo $sname2>config/sname2 ;;
	generate)
		GEN=1 ;;
	sign)
		SIGN=$(dialog --stdout --title "Please choose a signature image file" --fselect $HOME/ 14 48 --output-fd 1)
		cp $SIGN template/word/media/image2.png
		cp $SIGN template/word/media/image5.png ;;
	ssign1)
		SIGN1=$(dialog --stdout --title "Please choose a signature image file" --fselect $HOME/ 14 48 --output-fd 1)
		cp $SIGN1 template/word/media/image3.png
		cp $SIGN1 template/word/media/image6.png ;;
	sID)
		studentID=$(dialog --inputbox "Enter your studentID:" 8 40 --output-fd 1) 
		echo $studentID > config/sID ;;
	progr)
		programme=$(dialog --menu "pick one" 20 40 10 MPhil "MPhil" PhD "PhD" --output-fd 1) 
		echo $programme > config/programme ;;
esac
done
cp -r template tmp
sed -i'' "s/MYNAME/$(cat config/myname)/" tmp/word/document.xml
sed -i'' "s/SNAME1/$(cat config/sname1)/" tmp/word/document.xml
sed -i'' "s/SNAME2/$(cat config/sname2)/" tmp/word/document.xml
sed -i'' "s/PROGRAMME_HERE/$(cat config/programme)/" tmp/word/document.xml
sed -i'' "s/TEXTAREA1/$(cat config/current_state)/" tmp/word/document.xml
sed -i'' "s/TEXTAREA2/$(cat config/do_next)/" tmp/word/document.xml
sed -i'' "s/2017-04-24/$DATE/" tmp/word/document.xml
sed -i'' "s/2017-05-08/$PROPOSED_DATE/" tmp/word/document.xml
dtmp=$(date -d $DATE +"%d\/%m\/%Y")
sed -i'' "s/24\/04\/2017/$dtmp/" tmp/word/document.xml
dtmp=$(date -d $PROPOSED_DATE +"%d\/%m\/%Y")
sed -i'' "s/08\/05\/2017/$dtmp/" tmp/word/document.xml
for (( i=0; i<${#studentID}; i++ )); do
	sed -i'' "s/\<STUD_ID_$i\>/${studentID:$i:1}/" tmp/word/document.xml
done
cd tmp 
rm ../pgr.docx
zip ../pgr.docx -r * 
cd ../
rm -r tmp
