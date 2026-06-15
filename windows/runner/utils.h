#ifndef RUNNER_UTILS_H_
#define RUNNER_UTILS_H_

#include <string>
#include <vector>

// Creates a console for the process, and redirects stdout and stderr to
// it for both the runner and the Flutter library.
void CreateAndAttachConsole();

// Takes a list of command line arguments in UTF-8 and returns an equivalent
// vector of UTF-16 strings.
std::vector<std::string> GetCommandLineArguments();

#endif  // RUNNER_UTILS_H_
