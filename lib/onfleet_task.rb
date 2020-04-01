class OnfleetTask < Onfleet::Task
  STATES = {
    0 => 'Unassigned: task has not yet been assigned to a worker.',
    1 => 'Assigned: task has been assigned to a worker.',
    2 => 'Active: task has been started by its assigned worker.',
    3 => 'Completed: task has been completed by its assigned worker. Includes both successful and failed completions.'
  }


end
