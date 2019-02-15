package io.flutter.plugins.googlemaps;

import java.util.Map;

class MarkerUpdate {

  // This needs to be kept in sync with MarkerUpdateEventType on dart side.
  // These are `MarkerUpdateEventType.add`, `MarkerUpdateEventType.remove` and
  // `MarkerUpdateEventType.update` as raw strings.
  enum UpdateEventType {
    ADD,
    REMOVE,
    UPDATE
  }

  private final MarkerId markerId;
  private final UpdateEventType updateEventType;

  // This field is ignored from hashCode and equals.
  private final Object changes;

  static MarkerUpdate from(Object rawMarkerUpdate) {
    Map<String, Object> update = (Map<String, Object>) rawMarkerUpdate;
    String markerIdString = (String) update.get("markerId");
    String updateEventTypeString = (String) update.get("updateEventType");
    Object changes = update.get("changes");
    if (markerIdString == null || updateEventTypeString == null) {
      throw new IllegalArgumentException(
          "Invalid MarkerUpdate object. markerId or updateEventType was null.");
    }

    UpdateEventType eventType = getUpdateEventType(updateEventTypeString);
    MarkerId markerId = new MarkerId(markerIdString);
    return new MarkerUpdate(markerId, eventType, changes);
  }

  private static UpdateEventType getUpdateEventType(String updateEventTypeString) {
    switch (updateEventTypeString) {
      case "MarkerUpdateEventType.add":
        return UpdateEventType.ADD;
      case "MarkerUpdateEventType.update":
        return UpdateEventType.UPDATE;
      case "MarkerUpdateEventType.remove":
        return UpdateEventType.REMOVE;
      default:
        throw new IllegalArgumentException("Unknown updateEventType: " + updateEventTypeString);
    }
  }

  private MarkerUpdate(MarkerId markerId, UpdateEventType updateEventType, Object changes) {
    this.markerId = markerId;
    this.updateEventType = updateEventType;
    this.changes = changes;
  }

  MarkerId getMarkerId() {
    return markerId;
  }

  UpdateEventType getUpdateEventType() {
    return updateEventType;
  }

  void sinkChanges(MarkerOptionsSink sink) {
    Convert.interpretMarkerOptions(changes, sink);
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }

    MarkerUpdate that = (MarkerUpdate) o;

    if (!markerId.equals(that.markerId)) {
      return false;
    }
    return updateEventType == that.updateEventType;
  }

  @Override
  public int hashCode() {
    int result = markerId.hashCode();
    result = 31 * result + updateEventType.hashCode();
    return result;
  }

  @Override
  public String toString() {
    return "MarkerUpdate{"
        + "markerId="
        + markerId
        + ", updateEventType="
        + updateEventType
        + ", changes="
        + changes
        + '}';
  }
}
