"""utilities to adjust the UI of the widgets"""
import os
from .utils_core import getlayer_byname, check_layer_type, read_settings

def set_layer_substring(subString):
    """set layer subset according (you can check the subset under properties of the layer)"""
    layerNames = read_settings("SELECT child_layer FROM config_bouwlaag;", True)
    for layerName in layerNames:
        layer = getlayer_byname(layerName[0])
        layer.setSubsetString(subString)

def set_lengte_oppervlakte_visibility(widget, lengteTF, straalTF, oppTF, offsetTF):
    """change UI based on drawing lines/polygons"""
    widget.lengte_label.setVisible(lengteTF)
    widget.lengte.setVisible(lengteTF)
    widget.straal.setVisible(straalTF)
    widget.straal_label.setVisible(straalTF)
    widget.straal_button.setVisible(straalTF)
    widget.straal_button.setCheckable(straalTF)
    widget.oppervlakte_label.setVisible(oppTF)
    widget.oppervlakte.setVisible(oppTF)
    widget.offset.setVisible(offsetTF)
    widget.offset_label.setVisible(offsetTF)
    widget.offset_button.setVisible(offsetTF)
    widget.offset_button.setCheckable(offsetTF)

def read_config_file(file, layerName):
    """Read lines from input file and convert to list"""
    configList = []
    basepath = os.path.dirname(__file__)
    if layerName is None:
        layerName = []
    if basepath:
        os.chdir(basepath)
    with open("../" + file, "r") as inputFile:
        lines = inputFile.read().splitlines()
    for line in lines:
        configList.append(layerName + line.split(','))
    inputFile.close()
    return configList

def get_actions(whichConfig):
    """connect buttons and signals to the real action run"""
    #skip first line because of header
    editableLayerNames = []
    moveLayerNames = []
    actionList = []
    query = "SELECT child_layer, bestand FROM '{}'".format(whichConfig)
    layers = read_settings(query, True)
    for layer in layers:
        layerName = layer[0]
        csvPath = layer[1]
        if csvPath:
            editableLayerNames.append(layerName)
            layer = getlayer_byname(layerName)
            layerType = check_layer_type(layer)
            if layerType == "Point":
                moveLayerNames.append(layerName)
            actionList.append(read_config_file(csvPath, [layerName]))
    return actionList, editableLayerNames, moveLayerNames
