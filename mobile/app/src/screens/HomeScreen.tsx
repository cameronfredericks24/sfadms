import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useNavigation } from '@react-navigation/native';

interface KpiData {
  coverage: number;
  dropSize: number;
  linesPerOrder: number;
  promoUptake: number;
}

const HomeScreen: React.FC = () => {
  const navigation = useNavigation();
  const [kpiData, setKpiData] = useState<KpiData>({
    coverage: 0,
    dropSize: 0,
    linesPerOrder: 0,
    promoUptake: 0
  });

  useEffect(() => {
    loadKpiData();
  }, []);

  const loadKpiData = async () => {
    // TODO: Fetch from SmartStore or Salesforce API
    setKpiData({
      coverage: 92,
      dropSize: 245,
      linesPerOrder: 8,
      promoUptake: 67
    });
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Today's Performance</Text>
      </View>

      <View style={styles.kpiGrid}>
        <View style={styles.kpiCard}>
          <Text style={styles.kpiValue}>{kpiData.coverage}%</Text>
          <Text style={styles.kpiLabel}>Coverage</Text>
        </View>

        <View style={styles.kpiCard}>
          <Text style={styles.kpiValue}>{kpiData.dropSize}</Text>
          <Text style={styles.kpiLabel}>Avg Drop Size</Text>
        </View>

        <View style={styles.kpiCard}>
          <Text style={styles.kpiValue}>{kpiData.linesPerOrder}</Text>
          <Text style={styles.kpiLabel}>Lines/Order</Text>
        </View>

        <View style={styles.kpiCard}>
          <Text style={styles.kpiValue}>{kpiData.promoUptake}%</Text>
          <Text style={styles.kpiLabel}>Promo Uptake</Text>
        </View>
      </View>

      <View style={styles.actions}>
        <TouchableOpacity 
          style={styles.actionButton}
          onPress={() => navigation.navigate('BeatToday' as never)}>
          <Text style={styles.actionButtonText}>View Today's Route</Text>
        </TouchableOpacity>

        <TouchableOpacity 
          style={styles.actionButton}
          onPress={() => navigation.navigate('SyncCenter' as never)}>
          <Text style={styles.actionButtonText}>Sync Data</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5'
  },
  header: {
    padding: 20,
    backgroundColor: '#0070d2'
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white'
  },
  kpiGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    padding: 10
  },
  kpiCard: {
    width: '48%',
    backgroundColor: 'white',
    margin: '1%',
    padding: 20,
    borderRadius: 8,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3
  },
  kpiValue: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#0070d2'
  },
  kpiLabel: {
    fontSize: 14,
    color: '#666',
    marginTop: 8
  },
  actions: {
    padding: 20
  },
  actionButton: {
    backgroundColor: '#0070d2',
    padding: 16,
    borderRadius: 8,
    marginBottom: 12,
    alignItems: 'center'
  },
  actionButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600'
  }
});

export default HomeScreen;
