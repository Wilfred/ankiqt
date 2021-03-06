#!/bin/bash
#
# generate python files based on the designer ui files
#

if [ ! -d "designer" ]
then
    echo "Please run this from the project root"
    exit
fi

mkdir -p ankiqt/forms

if [ xDarwin = x$(uname) ]
then
    if [ -e /Library/Frameworks/Python.framework/Versions/2.5/bin/pyuic4 ]
    then
        pyuic=/Library/Frameworks/Python.framework/Versions/2.5/bin/pyuic4
        pyrcc=/Library/Frameworks/Python.framework/Versions/2.5/bin/pyrcc4
    elif [ -e /opt/local/Library/Frameworks/Python.framework/Versions/2.5/bin/pyuic4 ]
    then
        pyuic=/opt/local/Library/Frameworks/Python.framework/Versions/2.5/bin/pyuic4
        pyrcc=/opt/local/Library/Frameworks/Python.framework/Versions/2.5/bin/pyrcc4
    elif [ -e /System/Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4 ]
    then
        pyuic=/System/Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4
        pyrcc=/System/Library/Frameworks/Python.framework/Versions/2.6/bin/pyrcc4
    elif [ -e /Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4 ]
    then
        pyuic=/Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4
        pyrcc=/Library/Frameworks/Python.framework/Versions/2.6/bin/pyrcc4
    elif [ -f /opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4 ]
    then
        pyuic=/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/pyuic4
        pyrcc=/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/pyrcc4
    else
        echo 'Unable to find pyuic4. Try `port install py-pyqt4`?'
        exit
    fi
else
    pyuic=pyuic4
    pyrcc=pyrcc4
fi

init=ankiqt/forms/__init__.py
temp=ankiqt/forms/scratch
rm -f $init $temp
echo "# This file auto-generated by build_ui.sh. Don't edit." > $init
echo "__all__ = [" >> $init

echo "Generating forms.."
for i in designer/*.ui
do
    base=$(echo $i | perl -pe 's/\.ui//; s%designer/%%;')
    py=$(echo $i | perl -pe 's/\.ui/.py/; s%designer%ankiqt/forms%;')
    echo " * "$py
    $pyuic $i -o $py
    echo "	\"$base\"," >> $init
    echo "import $base" >> $temp
    # munge the output to use gettext
    perl -pi.bak -e 's/QtGui.QApplication.translate\(".*?", /_(/; s/, None, QtGui.*/))/' $py
    # remove the 'created' time, to avoid flooding the version control system
    perl -pi.bak -e 's/^# Created:.*$//' $py
    rm $py.bak
done
echo "]" >> $init
cat $temp >> $init
rm $temp

# use older integer format so qt4.4 still works
sed -i 's/setProperty("value", 14)/setProperty("value", QtCore.QVariant(14))/' ankiqt/forms/displayproperties.py

echo "Building resources.."
$pyrcc icons.qrc -o icons_rc.py
