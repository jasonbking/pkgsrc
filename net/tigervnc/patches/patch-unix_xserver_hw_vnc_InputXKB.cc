$NetBSD: patch-unix_xserver_hw_vnc_InputXKB.cc,v 1.1 2015/02/08 19:42:09 wiz Exp $

--- unix/xserver/hw/vnc/InputXKB.cc.orig	2013-05-30 14:53:40.000000000 +0000
+++ unix/xserver/hw/vnc/InputXKB.cc
@@ -232,10 +232,7 @@ void InputDevice::PrepareInputDevices(vo
 
 unsigned InputDevice::getKeyboardState(void)
 {
-	DeviceIntPtr master;
-
-	master = GetMaster(keyboardDev, KEYBOARD_OR_FLOAT);
-	return XkbStateFieldFromRec(&master->key->xkbInfo->state);
+	return XkbStateFieldFromRec(&keyboardDev->master->key->xkbInfo->state);
 }
 
 unsigned InputDevice::getLevelThreeMask(void)
@@ -256,7 +253,7 @@ unsigned InputDevice::getLevelThreeMask(
 			return 0;
 	}
 
-	xkb = GetMaster(keyboardDev, KEYBOARD_OR_FLOAT)->key->xkbInfo->desc;
+	xkb = keyboardDev->master->key->xkbInfo->desc;
 
 	act = XkbKeyActionPtr(xkb, keycode, state);
 	if (act == NULL)
@@ -281,7 +278,7 @@ KeyCode InputDevice::pressShift(void)
 	if (state & ShiftMask)
 		return 0;
 
-	xkb = GetMaster(keyboardDev, KEYBOARD_OR_FLOAT)->key->xkbInfo->desc;
+	xkb = keyboardDev->master->key->xkbInfo->desc;
 	for (key = xkb->min_key_code; key <= xkb->max_key_code; key++) {
 		XkbAction *act;
 		unsigned char mask;
@@ -318,7 +315,7 @@ std::list<KeyCode> InputDevice::releaseS
 	if (!(state & ShiftMask))
 		return keys;
 
-	master = GetMaster(keyboardDev, KEYBOARD_OR_FLOAT);
+	master = keyboardDev->master;
 	xkb = master->key->xkbInfo->desc;
 	for (key = xkb->min_key_code; key <= xkb->max_key_code; key++) {
 		XkbAction *act;
@@ -371,7 +368,7 @@ KeyCode InputDevice::pressLevelThree(voi
 			return 0;
 	}
 
-	xkb = GetMaster(keyboardDev, KEYBOARD_OR_FLOAT)->key->xkbInfo->desc;
+	xkb = keyboardDev->master->key->xkbInfo->desc;
 
 	act = XkbKeyActionPtr(xkb, keycode, state);
 	if (act == NULL)
@@ -399,7 +396,7 @@ std::list<KeyCode> InputDevice::releaseL
 	if (!(state & mask))
 		return keys;
 
-	master = GetMaster(keyboardDev, KEYBOARD_OR_FLOAT);
+	master = keyboardDev->master;
 	xkb = master->key->xkbInfo->desc;
 	for (key = xkb->min_key_code; key <= xkb->max_key_code; key++) {
 		XkbAction *act;
@@ -440,7 +437,7 @@ KeyCode InputDevice::keysymToKeycode(Key
 	if (new_state != NULL)
 		*new_state = state;
 
-	xkb = GetMaster(keyboardDev, KEYBOARD_OR_FLOAT)->key->xkbInfo->desc;
+	xkb = keyboardDev->master->key->xkbInfo->desc;
 	for (key = xkb->min_key_code; key <= xkb->max_key_code; key++) {
 		unsigned int state_out;
 		KeySym dummy;
@@ -497,7 +494,7 @@ bool InputDevice::isLockModifier(KeyCode
 	XkbDescPtr xkb;
 	XkbAction *act;
 
-	xkb = GetMaster(keyboardDev, KEYBOARD_OR_FLOAT)->key->xkbInfo->desc;
+	xkb = keyboardDev->master->key->xkbInfo->desc;
 
 	act = XkbKeyActionPtr(xkb, keycode, state);
 	if (act == NULL)
@@ -535,7 +532,7 @@ bool InputDevice::isAffectedByNumLock(Ke
 	if (numlock_keycode == 0)
 		return false;
 
-	xkb = GetMaster(keyboardDev, KEYBOARD_OR_FLOAT)->key->xkbInfo->desc;
+	xkb = keyboardDev->master->key->xkbInfo->desc;
 
 	act = XkbKeyActionPtr(xkb, numlock_keycode, state);
 	if (act == NULL)
@@ -569,7 +566,7 @@ KeyCode InputDevice::addKeysym(KeySym ke
 	KeySym *syms;
 	KeySym upper, lower;
 
-	master = GetMaster(keyboardDev, KEYBOARD_OR_FLOAT);
+	master = keyboardDev->master;
 	xkb = master->key->xkbInfo->desc;
 	for (key = xkb->max_key_code; key >= xkb->min_key_code; key--) {
 		if (XkbKeyNumGroups(xkb, key) == 0)
