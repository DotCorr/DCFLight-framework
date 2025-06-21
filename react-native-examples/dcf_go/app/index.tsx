import React, { useState } from 'react';
import { View, Text, Modal, Button, StyleSheet, SafeAreaView } from 'react-native';

export default function ModalStackingTest() {
  const [modal1Visible, setModal1Visible] = useState(false);
  const [modal2Visible, setModal2Visible] = useState(false);
  const [modal3Visible, setModal3Visible] = useState(false);

  // Helper function to reset all states
  const resetAllModals = () => {
    setModal1Visible(false);
    setModal2Visible(false);
    setModal3Visible(false);
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>React Native Modal Stacking Test</Text>
        <Text style={styles.subtitle}>Test how React Native handles multiple modals</Text>
        
        <View style={styles.buttonContainer}>
          <Button
            title="Open Modal 1"
            onPress={() => {
              console.log('Opening Modal 1');
              setModal1Visible(true);
            }}
          />
          
          <Button
            title="Reset All"
            onPress={resetAllModals}
            color="gray"
          />
        </View>
        
        <Text style={styles.status}>
          Modal 1: {modal1Visible ? 'OPEN' : 'CLOSED'} | 
          Modal 2: {modal2Visible ? 'OPEN' : 'CLOSED'} | 
          Modal 3: {modal3Visible ? 'OPEN' : 'CLOSED'}
        </Text>
      </View>

      {/* Modal 1 */}
      <Modal
        visible={modal1Visible}
        animationType="slide"
        presentationStyle="pageSheet"
        onRequestClose={() => {
          console.log('Modal 1 close requested');
          setModal1Visible(false);
        }}
      >
        <SafeAreaView style={[styles.modalContainer, { backgroundColor: '#ffebee' }]}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>🔴 Modal 1</Text>
            <Text style={styles.modalText}>This is the first modal</Text>
            <Text style={styles.status}>
              Current stack: Modal 1 = {modal1Visible ? 'OPEN' : 'CLOSED'}
            </Text>
            
            <View style={styles.buttonContainer}>
              <Button
                title="Open Modal 2 (Stack on top)"
                onPress={() => {
                  console.log('Modal 1 → Opening Modal 2');
                  setModal2Visible(true);
                }}
              />
              <Button
                title="Close Modal 1"
                onPress={() => {
                  console.log('Closing Modal 1');
                  setModal1Visible(false);
                }}
                color="red"
              />
            </View>
          </View>
        </SafeAreaView>
      </Modal>

      {/* Modal 2 */}
      <Modal
        visible={modal2Visible}
        animationType="slide"
        presentationStyle="pageSheet"
        onRequestClose={() => {
          console.log('Modal 2 close requested');
          setModal2Visible(false);
        }}
      >
        <SafeAreaView style={[styles.modalContainer, { backgroundColor: '#e3f2fd' }]}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>🔵 Modal 2</Text>
            <Text style={styles.modalText}>This is the second modal (should be on top of Modal 1)</Text>
            <Text style={styles.status}>
              Current stack: Modal 1 = {modal1Visible ? 'OPEN' : 'CLOSED'}, Modal 2 = {modal2Visible ? 'OPEN' : 'CLOSED'}
            </Text>
            
            <View style={styles.buttonContainer}>
              <Button
                title="Open Modal 3 (Stack on top)"
                onPress={() => {
                  console.log('Modal 2 → Opening Modal 3');
                  setModal3Visible(true);
                }}
              />
              <Button
                title="Close Modal 2"
                onPress={() => {
                  console.log('Closing Modal 2');
                  setModal2Visible(false);
                }}
                color="red"
              />
            </View>
          </View>
        </SafeAreaView>
      </Modal>

      {/* Modal 3 */}
      <Modal
        visible={modal3Visible}
        animationType="slide"
        presentationStyle="pageSheet"
        onRequestClose={() => {
          console.log('Modal 3 close requested');
          setModal3Visible(false);
        }}
      >
        <SafeAreaView style={[styles.modalContainer, { backgroundColor: '#e8f5e8' }]}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>🟢 Modal 3</Text>
            <Text style={styles.modalText}>This is the third modal (should be on top of Modal 1 & 2)</Text>
            <Text style={styles.status}>
              Full stack: Modal 1 = {modal1Visible ? 'OPEN' : 'CLOSED'}, Modal 2 = {modal2Visible ? 'OPEN' : 'CLOSED'}, Modal 3 = {modal3Visible ? 'OPEN' : 'CLOSED'}
            </Text>
            
            <View style={styles.buttonContainer}>
              <Button
                title="Close Modal 3 Only"
                onPress={() => {
                  console.log('Closing Modal 3');
                  setModal3Visible(false);
                }}
                color="red"
              />
              <Button
                title="Close All Modals"
                onPress={() => {
                  console.log('Closing all modals');
                  resetAllModals();
                }}
                color="orange"
              />
            </View>
          </View>
        </SafeAreaView>
      </Modal>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginBottom: 30,
    textAlign: 'center',
  },
  status: {
    fontSize: 12,
    color: '#333',
    marginTop: 20,
    textAlign: 'center',
    fontFamily: 'monospace',
  },
  buttonContainer: {
    gap: 15,
    marginVertical: 20,
    width: '100%',
    maxWidth: 300,
  },
  modalContainer: {
    flex: 1,
    margin: 0,
  },
  modalContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  modalTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 10,
    textAlign: 'center',
  },
  modalText: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 20,
    color: '#333',
  },
});
