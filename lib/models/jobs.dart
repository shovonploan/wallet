library job;

import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/database/database.dart';
import 'package:wallet/constants/common.dart';
import 'package:meta/meta.dart';
import 'package:event_bus/event_bus.dart';

String _tableName = "Job";

// Create a global event bus instance
final EventBus eventBus = EventBus();

// Define JobState Enum
enum JobStateEnum { Completed, InProcess, Scheduled, Failed }

// Define JobType Enum
enum JobType { Default, Authentication, DataProcessing, Notification }

@immutable
class Job extends DBGrain {
  @override
  final String id;
  final String name;
  final String task;
  final DateTime executionTime;
  final JobStateEnum state;
  final int retry;
  final int priority;
  final JobType jobType;
  final DateTime createdAt;
  final DateTime? lastExecutionTime;

  Job.Ctor(String name, String task, DateTime executionTime,
      {JobStateEnum state = JobStateEnum.Scheduled,
      int retry = 1,
      int priority = 0,
      JobType jobType = JobType.Default})
      : this(
          id: generateNewUuid(),
          name: name,
          task: task,
          executionTime: executionTime,
          state: state,
          retry: retry,
          priority: priority,
          jobType: jobType,
          createdAt: DateTime.now(),
          lastExecutionTime: null,
        );
  Job.defaultCtor()
      : this(
          id: '',
          name: '',
          task: '',
          executionTime: DateTime.now(),
          state: JobStateEnum.Scheduled,
          retry: 1,
          priority: 0,
          jobType: JobType.Default,
          createdAt: DateTime.now(),
          lastExecutionTime: null,
        );

  Job({
    required this.id,
    required this.name,
    required this.task,
    required this.executionTime,
    required this.state,
    required this.retry,
    required this.priority,
    required this.jobType,
    required this.createdAt,
    this.lastExecutionTime,
  });

  Job copyWith({
    String? id,
    String? name,
    String? task,
    DateTime? executionTime,
    JobStateEnum? state,
    int? retry,
    int? priority,
    JobType? jobType,
    DateTime? createdAt,
    DateTime? lastExecutionTime,
  }) {
    return Job(
      id: id ?? this.id,
      name: name ?? this.name,
      task: task ?? this.task,
      executionTime: executionTime ?? this.executionTime,
      state: state ?? this.state,
      retry: retry ?? this.retry,
      priority: priority ?? this.priority,
      jobType: jobType ?? this.jobType,
      createdAt: createdAt ?? this.createdAt,
      lastExecutionTime: lastExecutionTime ?? this.lastExecutionTime,
    );
  }

  Map<String, dynamic> _toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'task': task,
      'executionTime': executionTime.toIso8601String(),
      'state': state.toString(),
      'retry': retry,
      'priority': priority,
      'jobType': jobType.toString(),
      'createdAt': createdAt.toIso8601String(),
      'lastExecutionTime': lastExecutionTime?.toIso8601String(),
      'codecVersion': codecVersion,
    };
  }

  factory Job._fromMap(Map<String, dynamic> map) {
    final int dbCodecVersion = map['codecVersion'] as int;

    if (dbCodecVersion == 1) {
      return Job(
        id: map['id'] as String,
        name: map['name'] as String,
        task: map['task'] as String,
        executionTime: DateTime.parse(map['executionTime'] as String),
        state:
            JobStateEnum.values.firstWhere((e) => e.toString() == map['state']),
        retry: map['retry'] as int,
        priority: map['priority'] as int,
        jobType:
            JobType.values.firstWhere((e) => e.toString() == map['jobType']),
        createdAt: DateTime.parse(map['createdAt'] as String),
        lastExecutionTime: map['lastExecutionTime'] != null
            ? DateTime.parse(map['lastExecutionTime'] as String)
            : null,
      );
    } else {
      return Job.defaultCtor();
    }
  }

  String toJson() => json.encode(_toMap());

  factory Job.fromJson(String source) =>
      Job._fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Job(id: $id, name: $name, task: $task, executionTime: $executionTime, state: $state, retry: $retry, priority: $priority, jobType: $jobType, createdAt: $createdAt, lastExecutionTime: $lastExecutionTime)';

  @override
  bool operator ==(covariant Job other) {
    if (identical(this, other)) return true;
    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  final String tableName = _tableName;
  @override
  final Map<String, String> indexs = {};

  @override
  String insert() {
    return super.DBInsert(toJson());
  }

  @override
  String customInsert() {
    return '';
  }

  String update(Job newGrain) {
    return super.DBUpdate(newGrain.toJson());
  }

  @override
  final int codecVersion = 1;
}

//---------------State-----------------------
abstract class JobState extends Equatable {
  const JobState();
  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class JobLoaded extends JobState {
  final List<Job> jobs;
  const JobLoaded(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class JobError extends JobState {
  final String message;
  const JobError(this.message);

  @override
  List<Object?> get props => [message];
}

//--------------Event----------------------
abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class LoadJobs extends JobEvent {}

class AddJob extends JobEvent {
  final String name;
  final String task;
  final DateTime executionTime;
  final int priority;
  final JobType jobType;

  const AddJob(this.name, this.task, this.executionTime,
      {this.priority = 0, this.jobType = JobType.Default});

  @override
  List<Object?> get props => [name, task, executionTime, priority, jobType];
}

class UpdateJob extends JobEvent {
  final Job job;
  final String newName;
  final String newTask;
  final DateTime newExecutionTime;
  final JobStateEnum newState;
  final int newRetry;
  final int newPriority;
  final JobType newJobType;
  final DateTime? newLastExecutionTime;

  const UpdateJob(
      this.job,
      this.newName,
      this.newTask,
      this.newExecutionTime,
      this.newState,
      this.newRetry,
      this.newPriority,
      this.newJobType,
      this.newLastExecutionTime);

  @override
  List<Object?> get props => [
        job,
        newName,
        newTask,
        newExecutionTime,
        newState,
        newRetry,
        newPriority,
        newJobType,
        newLastExecutionTime
      ];
}

class DeleteJob extends JobEvent {
  final Job job;

  const DeleteJob(this.job);

  @override
  List<Object?> get props => [job];
}

class ExecuteJobs extends JobEvent {}

//---------------------bloc----------------
class JobBloc extends Bloc<JobEvent, JobState> {
  final DatabaseHelper _dbHelper;
  late Timer _timer;

  // Map to store task handlers
  final Map<String, Function(Job)> _taskHandlers = {};

  JobBloc(this._dbHelper) : super(JobInitial()) {
    on<LoadJobs>(_onLoadJobs);
    on<AddJob>(_onAddJob);
    on<UpdateJob>(_onUpdateJob);
    on<DeleteJob>(_onDeleteJob);
    on<ExecuteJobs>(_onExecuteJobs);

    // Register tasks in the map
    _taskHandlers["LogOut"] = _logOut;

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // TODO : Might need to verify state
      add(ExecuteJobs());
    });
  }

  // Task handler for LogOut
  void _logOut(Job job) {
    print("Executing LogOut task for job: ${job.id}");
    eventBus.fire(LogOutEvent(reason: "Scheduled LogOut from JobBloc"));
  }

  // TODO : Might need a refresh state
  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobState> emit) async {
    emit(JobLoading());
    try {
      List<Map<String, dynamic>> conditions = [
        {
          'key': 'state',
          'value': JobStateEnum.Scheduled.name,
          'comparison': '=',
          'operator': 'OR'
        },
        {'key': 'state', 'value': JobStateEnum.Failed.name, 'comparison': '='},
      ];

      final jobsJson = await _dbHelper.getIndexedGrain(
        _tableName,
        conditions,
      );

      final jobs = jobsJson.map((e) => Job.fromJson(e)).toList();

      emit(JobLoaded(jobs));
    } catch (e) {
      emit(const JobError('Failed to load jobs.'));
    }
  }

  // TODO: May not need to throw JobError, just change job state
  Future<void> _onAddJob(AddJob event, Emitter<JobState> emit) async {
    try {
      final newJob = Job.Ctor(event.name, event.task, event.executionTime,
          state: JobStateEnum.Scheduled,
          priority: event.priority,
          jobType: event.jobType);
      await _dbHelper.rawExecute(newJob.insert());
      await _dbHelper
          .rawExecute(newJob.DBInsertCIdx("state", newJob.state.name));
      add(LoadJobs());
    } catch (e) {
      emit(const JobError('Failed to add job.'));
    }
  }

  // TODO: on error catch retry
  Future<void> _onUpdateJob(UpdateJob event, Emitter<JobState> emit) async {
    try {
      await _dbHelper.rawExecute(event.job.update(event.job.copyWith(
        name: event.newName,
        task: event.newTask,
        executionTime: event.newExecutionTime,
        state: event.newState,
        retry: event.newRetry,
        priority: event.newPriority,
        jobType: event.newJobType,
        lastExecutionTime: event.newLastExecutionTime,
      ))).then((_){
        add(LoadJobs());
      });
    } catch (e) {
      emit(const JobError('Failed to update job.'));
    }
  }

  // TODO: May not need to throw JobError, just change job state
  Future<void> _onDeleteJob(DeleteJob event, Emitter<JobState> emit) async {
    try {
      await _dbHelper.rawDelete(event.job.tableName, event.job.id);
      add(LoadJobs());
    } catch (e) {
      emit(const JobError('Failed to delete job.'));
    }
  }

  Future<void> _onExecuteJobs(ExecuteJobs event, Emitter<JobState> emit) async {
    try {
      final currentState = state;
      if (currentState is JobLoaded) {
        final currentTime = DateTime.now();
        for (final job in currentState.jobs) {
          if (job.state == JobStateEnum.Scheduled &&
              job.executionTime.isBefore(currentTime)) {
            // Dynamically look up and execute the appropriate handler for the job task
            if (_taskHandlers.containsKey(job.task)) {
              _taskHandlers[job.task]?.call(job);
            }

            // Mark job as executed or retry if failed
            // TODO: may need to retry
            final updatedState = JobStateEnum.Completed;
            final updatedJob = job.copyWith(
                state: updatedState, lastExecutionTime: currentTime);
            await _dbHelper.rawExecute(job.update(updatedJob));
          }
        }
        add(LoadJobs());
      }
    } catch (e) {
      emit(const JobError('Failed to execute jobs.'));
    }
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}

// Define a custom event for logout
class LogOutEvent {
  final String reason;

  LogOutEvent({this.reason = 'Scheduled logout'});
}
