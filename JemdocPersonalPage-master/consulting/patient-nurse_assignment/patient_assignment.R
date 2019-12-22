if (!require("readxl")) {
  install.packages("readxl")
  library("readxl")
}

read_excel_allsheets <- function(filename) {
  sheets <- readxl::excel_sheets(filename)
  x <-    lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  names(x) <- sheets
  x
}

nurse_info <- read_excel("~/PatientAcuityNurseWorkload/Pt_Nurse_assign/NurseInfo.xlsx")
nurse_info <- as.data.frame(nurse_info)

input.files <- read_excel_allsheets(choose.files())

patients <- input.files$Patient_Info
patients <- as.data.frame(patients)
assignments <- input.files$Assignment
assignments <- as.data.frame(assignments)

assignments_copy <- assignments

# Optimization of assignments function:
optimize_assignment <- function(number_of_patients, patients_acuity, 
                                number_of_nurses, expected_percentage_workload) {
  assignment_cutoff <- seq(from = 0, to = 1,
                           length.out = number_of_nurses + 1)
  max_rand_assignments <- 1000
  
  patient_rand_num <- runif(n = number_of_patients)
  patient_assignment <- findInterval(x = patient_rand_num, vec = assignment_cutoff)
  while(length(table(patient_assignment)) < number_of_nurses) {
    patient_rand_num <- runif(n = number_of_patients)
    patient_assignment <- findInterval(x = patient_rand_num, vec = assignment_cutoff)
  }
  new_worload <- aggregate(patients_acuity ~ patient_assignment, FUN = sum)
  best_assignment_var <- var(new_worload[,2] / expected_percentage_workload)
  best_assignment <- patient_assignment
  
  for (i in 1:max_rand_assignments) {
    patient_rand_num <- runif(n = number_of_patients)
    patient_assignment <- findInterval(x = patient_rand_num, vec = assignment_cutoff)
    while(length(table(patient_assignment)) < number_of_nurses) {
      patient_rand_num <- runif(n = number_of_patients)
      patient_assignment <- findInterval(x = patient_rand_num, vec = assignment_cutoff)
    }
    new_worload <- aggregate(patients_acuity ~ patient_assignment, FUN = sum)
    new_assignment_var <- var(new_worload[,2] / expected_percentage_workload)
    if (new_assignment_var < best_assignment_var) {
      best_assignment <- patient_assignment
      best_assignment_var <- new_assignment_var
      print(best_assignment_var)
    }
  }
  best_worload <- aggregate(patients_acuity_this_hallway ~ best_assignment, FUN = sum)
  return(list(best_assignment = best_assignment, 
              best_assignment_var = best_assignment_var, 
              best_worload = best_worload))
}

## output!
write_to_output <- function(number_of_nurses, assignments, 
                            best_assignment, best_workload, patients) {
  for (nurse_index in 1:number_of_nurses) {
    nurse_infor_lookup_index <- which(nurse_info$Nurse_ID == assignments$Nurse_ID[nurse_index])
    assignments$Nurse_name[nurse_index] <- nurse_info$Nurse_name[nurse_infor_lookup_index]
    assignments$Pager[nurse_index] <- nurse_info$Pager_number[nurse_infor_lookup_index]
    assignments$Actual_workload <- best_workload$patients_acuity_this_hallway
    patients_assigned_to_this_nurse <- which(best_assignment == nurse_index)
    for (j in 1:length(patients_assigned_to_this_nurse)) {
      patient_index <- patients_assigned_to_this_nurse[j]
      patient_room_and_name <- paste(patients$Room_No[patient_index], 
                                     patients$Patient_name[patient_index])
      assignments[nurse_index, paste0("Patient",j)] <- patient_room_and_name
    }
    assignments$Isolation[nurse_index] <- sum(patients$Isolation[patients_assigned_to_this_nurse])
    assignments$Sitter[nurse_index] <- sum(patients$Sitter[patients_assigned_to_this_nurse])
    assignments$PCN[nurse_index] <- sum(patients$PCN[patients_assigned_to_this_nurse])
    assignments$ADT[nurse_index] <- sum(patients$ADT[patients_assigned_to_this_nurse])
    assignments$Telemetry[nurse_index] <- sum(patients$Telemetry[patients_assigned_to_this_nurse])
  }
  return(assignments)
}


# optimization for each hallway
for (hallway in levels(factor(patients$Hallway))) {
  patients_in_this_hallway <- patients[patients$Hallway == hallway,]
  assignments_in_this_hallway <- assignments[assignments$Hallway == hallway,]
  
  # set the number of patients in this hallway
  number_of_patients_this_hallway <- sum(!is.na(patients_in_this_hallway$Acuity_score))
  # input the patients acuity scores 
  patients_acuity_this_hallway <- patients_in_this_hallway$Acuity_score
  # set the number of nurses
  number_of_nurses_this_hallway <- length(assignments_in_this_hallway$Nurse_ID)
  # expected percentage workload
  expected_percentage_workload <- assignments_in_this_hallway$Expected_pct_workload
  
  # optimize assignments in this hallway
  result_this_hallway <- optimize_assignment(number_of_patients = number_of_patients_this_hallway,
                                patients_acuity = patients_acuity_this_hallway,
                                number_of_nurses = number_of_nurses_this_hallway,
                                expected_percentage_workload = expected_percentage_workload)

  # write to output
  assignments_in_this_hallway_copy <- write_to_output(number_of_nurses = number_of_nurses_this_hallway,
                                                 assignments = assignments_in_this_hallway, 
                                                 best_assignment = result_this_hallway$best_assignment, 
                                                 best_workload = result_this_hallway$best_worload, 
                                                 patients = patients_in_this_hallway)
  
  assignments_copy[assignments_copy$Hallway == hallway,] <- assignments_in_this_hallway_copy
}

dim(assignments_in_this_hallway)

assignments_copy

# Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jre1.8.0_161\\jre7')
# # write output back to Excel sheet
# if (!require("xlsx")) {
#   install.packages("xlsx")
#   library("xlsx")
# }
# xlsx::write.xlsx(assignments_copy, file="NurseAssignments-Mar6-day.xlsx", sheetName="Assignment", append=T, row.names=FALSE)

xlsx::write.xlsx(assignments_copy, file = "NurseAssignments-Mar26-day-filled.xlsx", row.names = F)

