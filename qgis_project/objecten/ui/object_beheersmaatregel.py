from qgis.PyQt.QtWidgets import QComboBox, QDialogButtonBox, QLineEdit
from qgis.core import QgsFeature, QgsSpatialIndex, QgsFeatureRequest
from qgis.utils import iface

def formOpen(dialog, layer, feature):
    myDialog = dialog
    myLayer = layer
    nameField = []
    nameValidate = []
    try:
        nameField.append(myDialog.findChild(QComboBox, "inzetfase"))
        nameField.append(myDialog.findChild(QComboBox, "maatregel_type_id"))
        okButton = dialog.findChild(QDialogButtonBox, "buttonBox")
        nameValidate.append(0)
        nameValidate.append(0)
        if not (len(nameField[0].currentText()) > 0):
            nameField[0].setStyleSheet("background-color: rgba(255, 107, 107, 150);")
            okButton.setEnabled(False)
        if not (len(nameField[1].currentText()) > 0):
            nameField[1].setStyleSheet("background-color: rgba(255, 107, 107, 150);")
            okButton.setEnabled(False)            
        nameField[0].currentIndexChanged.connect(lambda: validate_0(nameField, nameValidate, okButton))
        nameField[1].currentIndexChanged.connect(lambda: validate_1(nameField, nameValidate, okButton))
        bnOk = okButton.button(QDialogButtonBox.Ok)	
        bnOk.clicked.connect(lambda: applySave(myLayer, myDialog))
    except:
        pass
	
def applySave(myLayer, myDialog):
    myLayer.commitChanges()
    myDialog.save()

def validate_0(nameField, nameValidate, okButton):
    if (len(nameField[0].currentText()) > 0):
        nameField[0].setStyleSheet("")
        nameValidate[0] = 1
    if (sum(nameValidate) > 1):
        okButton.setEnabled(True)
        
def validate_1(nameField, nameValidate, okButton):
    if (len(nameField[1].currentText()) > 0):
        nameField[1].setStyleSheet("")
        nameValidate[1] = 1
    if (sum(nameValidate) > 1):
        okButton.setEnabled(True)