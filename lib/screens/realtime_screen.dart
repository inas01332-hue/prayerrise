import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class RealtimeScreen extends StatefulWidget {
  const RealtimeScreen({super.key});

  @override
  State<RealtimeScreen> createState() => _RealtimeScreenState();
}

class _RealtimeScreenState extends State<RealtimeScreen> {
  final List<dynamic> _events = [];
  late final StreamSubscription<PostgresChangeEvent> _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    final supabase = Supabase.instance.client;
    _subscription = supabase
        .channel('prayers-realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'prayers',
          callback: (payload) {
            setState(() {
              _events.add(payload);
            });
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Realtime Prayers Listener')),
      body: _events.isEmpty
          ? const Center(child: Text('No events yet'))
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final ev = _events[index];
                return ListTile(
                  title: Text('New row: ${ev['new'] ?? ev['record'] ?? ev}'),
                );
              },
            ),
    );
  }
}
