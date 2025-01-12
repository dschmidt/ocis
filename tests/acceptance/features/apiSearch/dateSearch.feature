Feature: date search
  As a user
  I want to do search resources by date

  Background:
    Given user "Alice" has been created with default attributes and without skeleton files

  Scenario Outline: search resources using different dav path
    Given using <dav-path-version> DAV path
    And user "Alice" has created folder "uploadFolder"
    When user "Alice" searches for 'Mtime:"today"' using the WebDAV API
    And the search result of user "Alice" should contain these entries:
      | /uploadFolder |
    Examples:
      | dav-path-version |
      | old              |
      | new              |
      | spaces           |


  Scenario Outline: search resources using different search patterns (KQL feature) in the personal space
    Given user "Alice" uploads a file "filesForUpload/textfile.txt" to "/today.txt" with mtime "today" via TUS inside of the space "Personal" using the WebDAV API
    And user "Alice" uploads a file "filesForUpload/textfile.txt" to "/yesterday.txt" with mtime "yesterday" via TUS inside of the space "Personal" using the WebDAV API
    And user "Alice" uploads a file "filesForUpload/textfile.txt" to "/lastWeek.txt" with mtime "lastWeek" via TUS inside of the space "Personal" using the WebDAV API
    And user "Alice" uploads a file "filesForUpload/textfile.txt" to "/lastMonth.txt" with mtime "lastMonth" via TUS inside of the space "Personal" using the WebDAV API
    And user "Alice" uploads a file "filesForUpload/textfile.txt" to "/lastYear.txt" with mtime "lastYear" via TUS inside of the space "Personal" using the WebDAV API
    And using spaces DAV path
    When user "Alice" searches for '<pattern>' using the WebDAV API
    Then the HTTP status code should be "207"
    And the search result of user "Alice" should contain these entries:
      | <search-result-1> |
      | <search-result-2> |
    But the search result of user "Alice" should not contain these entries:
      | <search-result-3> |
      | <search-result-4> |
    Examples:
      | pattern            | search-result-1 | search-result-2 | search-result-3 | search-result-4 |
      | Mtime:today        | /today.txt      |                 | /yesterday.txt  | /lastWeek.txt   |
      | Mtime:yesterday    | /yesterday.txt  |                 | /today.txt      |                 |
      | Mtime:"this week"  | /today.txt      |                 | /lastWeek.txt   | /lastMont.txt   |
      | Mtime:"this month" | /today.txt      |                 | /lastMont.txt   |                 |
      | Mtime:"last month" | /lastMonth.txt  |                 | /today.txt      |                 |
      | Mtime:"this year"  | /today.txt      |                 | /lastYear.txt   |                 |
      | Mtime:"last year"  | /lastYear.txt   |                 | /today.txt      |                 |
      | Mtime>=$today      | /today.txt      |                 | /yesterday.txt  |                 |
      | Mtime>$yesterday   | /today.txt      |                 |                 |                 |
      | Mtime>=$yesterday  | /today.txt      | /yesterday.txt  |                 |                 |
      # Mtime<$today. "<" has to be escaped
      | Mtime&lt;$today    | /yesterday.txt  | /lastYear.txt   | /today.txt      |                 |


  Scenario: search resources using different search patterns (KQL feature) in the shares folder
    Given user "Brian" has been created with default attributes and without skeleton files
    And using spaces DAV path
    And user "Alice" has created folder "sharedFolder"
    And user "Alice" uploads a file "filesForUpload/textfile.txt" to "/sharedFolder/yesterday.txt" with mtime "yesterday" via TUS inside of the space "Personal" using the WebDAV API
    And user "Alice" has shared folder "/sharedFolder" with user "Brian"
    And user "Brian" has accepted share "/sharedFolder" offered by user "Alice"
    When user "Brian" searches for "Mtime:yesterday" using the WebDAV API
    Then the HTTP status code should be "207"
    And the search result of user "Brian" should contain these entries:
      | sharedFolder/yesterday.txt |
    But the search result of user "Alice" should not contain these entries:
      | sharedFolder |
