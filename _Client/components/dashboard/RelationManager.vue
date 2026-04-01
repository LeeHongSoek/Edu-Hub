<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from "vue";
import IconUsers from "~/assets/icons/IconUsers.svg?component";
import IconGraphForce from "~/assets/icons/IconGraphForce.svg?component";
import IconSearch from "~/assets/icons/IconSearch.svg?component";
import IconClose from "~/assets/icons/IconClose.svg?component";

type RelationRoleId = "S" | "T" | "P";
type TargetKey = "parents" | "teachers" | "students" | "friends";

interface RelationTarget {
  key: TargetKey;
  label: string;
  roleId: RelationRoleId;
  description: string;
}

interface SearchPanelState {
  searchInput: string;
  searchQuery: string;
  currentPage: number;
  sliderValue: number;
  total: number;
  totalPages: number;
  items: any[];
  loading: boolean;
}

interface GraphNode {
  id: string;
  label: string;
  color: string;
  x: number;
  y: number;
  vx: number;
  vy: number;
  r: number;          // 반지름
  level: 0 | 1 | 2;  // 0=나, 1=그룹, 2=개인
  group?: string;     // 그룹 노드 id (2레벨 노드에서 사용)
  fixed?: boolean;
  pinned?: boolean;   // 드래그로 고정된 노드
}

interface GraphEdge {
  source: string;
  target: string;
}

const pageSize = 6;
const relationPageSize = 8;
const graphWidth = 860;
const graphHeight = 520;
const relations = ref<any[]>([]);
const relationLoading = ref(true);
const relationSearchInput = ref("");
const relationSearchQuery = ref("");
const relationCurrentPage = ref(1);
const relationSliderValue = ref(1);
const relationTotal = ref(0);
const relationTotalPages = ref(1);
const showConnectModal = ref(false);
const showGraphModal = ref(false);
const activeTargetKey = ref<TargetKey | "">("");
const submittingUserId = ref<string>("");
const feedbackMessage = ref("");
const hoveredGraphNodeId = ref<string>("");
const graphNodes = ref<GraphNode[]>([]);
const graphEdges = ref<GraphEdge[]>([]);
const allRelations = ref<any[]>([]);
const graphLoading = ref(false);
const draggingNodeId = ref<string | null>(null);
let graphAnimationFrame = 0;
const emit = defineEmits<{
  (event: "compose-message", user: any): void;
  (event: "open-message-thread", user: any): void;
}>();

const panelStates = reactive<Record<TargetKey, SearchPanelState>>({
  parents: createPanelState(),
  teachers: createPanelState(),
  students: createPanelState(),
  friends: createPanelState(),
});

const { apiBase, getAuthHeader } = useApi();
const userCookie = useCookie("user_info");

const userInfo = computed(() => {
  if (!userCookie.value) return null;
  try {
    return typeof userCookie.value === "string"
      ? JSON.parse(userCookie.value)
      : userCookie.value;
  } catch {
    return null;
  }
});

const myUserNo = computed(() => userInfo.value?.user_no ?? null);

const userRoleId = computed<RelationRoleId | "">(() => {
  const role = userInfo.value?.role_id ?? userInfo.value?.role ?? "";
  return ["S", "T", "P"].includes(role) ? role : "";
});

const relationTargets = computed<RelationTarget[]>(() => {
  if (userRoleId.value === "S") {
    return [
      {
        key: "friends",
        label: "친구",
        roleId: "S",
        description: "이름으로 다른 학생을 검색하고 친구 연결을 만들 수 있습니다.",
      },
      {
        key: "parents",
        label: "학부모",
        roleId: "P",
        description: "이름으로 학부모를 검색하고 바로 연결할 수 있습니다.",
      },
      {
        key: "teachers",
        label: "선생님",
        roleId: "T",
        description: "이름으로 선생님을 검색하고 바로 연결할 수 있습니다.",
      },
    ];
  }

  if (userRoleId.value === "P") {
    return [
      {
        key: "students",
        label: "학생",
        roleId: "S",
        description: "이름으로 학생을 검색하고 자녀 연결을 만들 수 있습니다.",
      },
    ];
  }

  if (userRoleId.value === "T") {
    return [
      {
        key: "students",
        label: "학생",
        roleId: "S",
        description: "이름으로 학생을 검색하고 수업 대상과 연결할 수 있습니다.",
      },
    ];
  }

  return [];
});

const activeTarget = computed(
  () =>
    relationTargets.value.find(
      (target) => target.key === activeTargetKey.value,
    ) ?? null,
);
const activePanel = computed(() => {
  if (!activeTarget.value) return null;
  return getPanelState(activeTarget.value.key);
});

const totalPages = computed(() => {
  if (!activePanel.value) return 1;
  return Math.max(
    1,
    activePanel.value.totalPages ||
      Math.ceil(activePanel.value.total / pageSize) ||
      1,
  );
});

const isSliderDisabled = computed(
  () => totalPages.value <= 1 || !activePanel.value,
);
const sliderPercentage = computed(() => {
  if (!activePanel.value || totalPages.value <= 1) return 0;
  return ((activePanel.value.sliderValue - 1) / (totalPages.value - 1)) * 100;
});

const pageStartItem = computed(() => {
  if (!activePanel.value || activePanel.value.total === 0) return 0;
  return (activePanel.value.currentPage - 1) * pageSize + 1;
});

const pageEndItem = computed(() => {
  if (!activePanel.value) return 0;
  return Math.min(
    activePanel.value.currentPage * pageSize,
    activePanel.value.total,
  );
});

const relationTotalPagesComputed = computed(() =>
  Math.max(1, relationTotalPages.value),
);
const relationIsSliderDisabled = computed(
  () => relationTotalPagesComputed.value <= 1,
);
const relationSliderPercentage = computed(() => {
  if (relationTotalPagesComputed.value <= 1) return 0;
  return (
    ((relationSliderValue.value - 1) / (relationTotalPagesComputed.value - 1)) *
    100
  );
});
const relationPageStartItem = computed(() => {
  if (relationTotal.value === 0) return 0;
  return (relationCurrentPage.value - 1) * relationPageSize + 1;
});
const relationPageEndItem = computed(() =>
  Math.min(relationCurrentPage.value * relationPageSize, relationTotal.value),
);

const hasConnectedRelations = computed(() => relationTotal.value > 0);
const hasCandidateResults = computed(
  () => !!activePanel.value && activePanel.value.total > 0,
);
const mainDisplayTotal = computed(() => {
  if (hasConnectedRelations.value) return relationTotal.value;
  return activePanel.value?.total ?? 0;
});
const mainDisplayTotalPages = computed(() => {
  if (hasConnectedRelations.value) return relationTotalPagesComputed.value;
  if (!activePanel.value) return 1;
  return Math.max(1, activePanel.value.totalPages || 1);
});
const mainDisplaySliderDisabled = computed(
  () => mainDisplayTotalPages.value <= 1,
);
const mainDisplaySliderValue = computed(() => {
  if (hasConnectedRelations.value) return relationSliderValue.value;
  return activePanel.value?.sliderValue ?? 1;
});
const mainDisplaySliderPercentage = computed(() => {
  if (mainDisplayTotalPages.value <= 1) return 0;
  return (
    ((mainDisplaySliderValue.value - 1) / (mainDisplayTotalPages.value - 1)) *
    100
  );
});
const mainDisplayPageStartItem = computed(() => {
  if (mainDisplayTotal.value === 0) return 0;
  if (hasConnectedRelations.value) return relationPageStartItem.value;
  return ((activePanel.value?.currentPage ?? 1) - 1) * pageSize + 1;
});
const mainDisplayPageEndItem = computed(() => {
  if (mainDisplayTotal.value === 0) return 0;
  if (hasConnectedRelations.value) return relationPageEndItem.value;
  if (!activePanel.value) return 0;
  return Math.min(activePanel.value.currentPage * pageSize, activePanel.value.total);
});

const relationSummary = computed(() => {
  if (userRoleId.value === "S") {
    return "학생은 친구, 학부모, 선생님을 이름으로 찾아 바로 연결할 수 있습니다.";
  }
  if (userRoleId.value === "P") {
    return "학부모는 학생을 이름으로 찾아 연결할 수 있습니다.";
  }
  if (userRoleId.value === "T") {
    return "선생님은 학생을 이름으로 찾아 연결할 수 있습니다.";
  }
  return "연결 관리 기능을 사용할 수 없습니다.";
});

const graphCenterNodeId = computed(() =>
  userInfo.value?.user_no ? `me-${userInfo.value.user_no}` : "me",
);

// 그룹 레이블 매핑
const groupLabel = (typeId: string): string => {
  if (typeId === "FRIEND") return "친구";
  if (typeId === "CHILD_PARENT" || typeId === "PARENT_CHILD") return "학부모";
  if (typeId === "PUPIL_TEACHER" || typeId === "TEACHER_PUPIL") return "선생님";
  if (typeId === "STUDENTS") return "학생";
  return "기타";
};

const graphData = computed(() => {
  const cx = graphWidth / 2;
  const cy = graphHeight / 2;
  const me = "나";
  const centerId = graphCenterNodeId.value;

  const centerNode: GraphNode = {
    id: centerId,
    label: me,
    color: "#818cf8",
    x: cx,
    y: cy,
    vx: 0,
    vy: 0,
    r: 36,
    level: 0,
    pinned: true, // 기본 위치 고정, 드래그 시 이동 가능
  };

  const nodes: GraphNode[] = [centerNode];
  const edges: GraphEdge[] = [];

  // 관계 타입별로 그루핑
  // 학생(S) 기준: FRIEND, CHILD_PARENT, PUPIL_TEACHER
  // 학부모(P) 기준: PARENT_CHILD
  // 선생님(T) 기준: TEACHER_PUPIL
  const groups = new Map<string, { label: string; users: any[] }>();

  allRelations.value.forEach((relation) => {
    const user = getOtherUser(relation);
    if (!user?.user_no) return;

    const targetRole = String(user.role_id || "").toUpperCase();
    const myRole = String(userRoleId.value || "").toUpperCase();

    // 1) 역할이 명확하면 역할 기준
    let label: string | null = null;
    if (targetRole === "S") {
      label = myRole === "S" ? "친구" : "학생";
    } else if (targetRole === "T") {
      label = "선생님";
    } else if (targetRole === "P") {
      label = "학부모";
    }

    // 2) 역할이 비어 있으면 관계 타입으로 추론 (백엔드가 role_id를 안 내려줄 경우)
    if (!label) {
      const typeId = String(relation?.relation_type_id || "").toUpperCase();
      label = groupLabel(typeId) || "기타";
    }

    if (!label) label = "기타";

    const groupId = `group-${label}`;
    if (!groups.has(groupId)) {
      groups.set(groupId, { label, users: [] });
    }
    const existing = groups.get(groupId)!.users;
    if (!existing.find((u: any) => u.user_no === user.user_no)) {
      existing.push(user);
    }
  });

  // 그룹 노드 및 개인 노드 배치
  const groupIds = [...groups.keys()];
  const groupCount = groupIds.length;

  groupIds.forEach((groupId, gi) => {
    const groupData = groups.get(groupId)!;
    // 그룹 노드를 나 주변에 방사형으로 배치
    const gAngle = (Math.PI * 2 * gi) / Math.max(groupCount, 1) - Math.PI / 2;
    const gRadius = 170;
    const gx = cx + Math.cos(gAngle) * gRadius;
    const gy = cy + Math.sin(gAngle) * gRadius;

    const groupNode: GraphNode = {
      id: groupId,
      label: `${groupData.label} (${groupData.users.length})`,
      color: "#6366f1",
      x: gx,
      y: gy,
      vx: (Math.random() - 0.5) * 1.5,
      vy: (Math.random() - 0.5) * 1.5,
      r: 20,
      level: 1,
    };
    nodes.push(groupNode);
    edges.push({ source: centerId, target: groupId });

    // 개인 노드를 그룹 노드 주변에 배치
    const users = groupData.users;
    users.forEach((user, ui) => {
      const pAngle = gAngle + ((ui - (users.length - 1) / 2) * Math.PI) / Math.max(users.length, 2) * 0.9;
      const pRadius = 120;
      const pid = `user-${user.user_no}`;
      // 이미 추가된 노드면 skip (동일인이 여러 그룹에 있는 경우는 없지만 방어)
      if (!nodes.find(n => n.id === pid)) {
        nodes.push({
          id: pid,
          label: user.username || "이름 없음",
          color: "#818cf8",
          x: gx + Math.cos(pAngle) * pRadius,
          y: gy + Math.sin(pAngle) * pRadius,
          vx: (Math.random() - 0.5) * 2,
          vy: (Math.random() - 0.5) * 2,
          r: 14,
          level: 2,
          group: groupId,
        });
      }
      edges.push({ source: groupId, target: pid });
    });
  });

  return { nodes, edges };
});

const graphEdgePositions = computed(() => {
  return graphEdges.value
    .map((edge) => {
      const source = graphNodes.value.find((node) => node.id === edge.source);
      const target = graphNodes.value.find((node) => node.id === edge.target);
      if (!source || !target) return null;
      return {
        source: edge.source,
        target: edge.target,
        x1: source.x,
        y1: source.y,
        x2: target.x,
        y2: target.y,
        // 엣지 스타일: 레벨0→1은 밝게, 레벨1→2는 어둡게
        isGroupEdge: source.level === 0 || target.level === 0,
      };
    })
    .filter((e): e is NonNullable<typeof e> => e !== null);
});

const startDragging = (nodeId: string) => {
  draggingNodeId.value = nodeId;
};

const handleGlobalMouseMove = (event: MouseEvent) => {
  if (!draggingNodeId.value) return;
  const svg = document.querySelector(".graph-svg") as SVGSVGElement;
  if (!svg) return;

  const CTM = svg.getScreenCTM();
  if (!CTM) return;

  const x = (event.clientX - CTM.e) / CTM.a;
  const y = (event.clientY - CTM.f) / CTM.d;

  const node = graphNodes.value.find((n) => n.id === draggingNodeId.value);
  if (node) {
    node.x = x;
    node.y = y;
    node.vx = 0;
    node.vy = 0;
  }
};

const stopDragging = () => {
  if (!draggingNodeId.value) return;
  const node = graphNodes.value.find((n) => n.id === draggingNodeId.value);
  if (node && !node.fixed) {
    node.pinned = true; // 드래그 드롭 후 위치 고정
    node.vx = 0;
    node.vy = 0;
  }
  draggingNodeId.value = null;
};

const loadAllRelationsForGraph = async () => {
  graphLoading.value = true;
  try {
    const data = await $fetch(`${apiBase.value}/dashboard/relations`, {
      headers: getAuthHeader(),
      query: {
        page: 1,
        limit: 24, // 백엔드 safeLimit 최대치
      },
    });
    const response = data as { items: any[]; total: number };
    allRelations.value = response.items ?? [];
  } catch (err) {
    console.error("그래프용 전체 관계 로드 실패:", err);
    allRelations.value = [];
  } finally {
    graphLoading.value = false;
  }
};

const openGraphModal = async () => {
  // 헤더 클릭 시에도 최신 인맥을 가져오도록 강제 호출
  await loadRelations();
  showGraphModal.value = true;
  await loadAllRelationsForGraph();
};

const closeGraphModal = () => {
  showGraphModal.value = false;
  hoveredGraphNodeId.value = "";
};

const stopGraphSimulation = () => {
  if (graphAnimationFrame) {
    cancelAnimationFrame(graphAnimationFrame);
    graphAnimationFrame = 0;
  }
};

const startGraphSimulation = () => {
  stopGraphSimulation();

  const tick = () => {
    const nodes = graphNodes.value;
    const edges = graphEdges.value;

    if (!showGraphModal.value || nodes.length === 0) {
      stopGraphSimulation();
      return;
    }

    // --- 반발력 (같은 레벨 노드끼리만 밀어냄, 멀어질수록 약해짐) ---
    for (let i = 0; i < nodes.length; i += 1) {
      for (let j = i + 1; j < nodes.length; j += 1) {
        const a = nodes[i];
        const b = nodes[j];
        // 다른 레벨이면 반발력 없음 (계층을 어지럽히지 않도록)
        if (a.level !== b.level) continue;
        // 드래그로 고정된 노드는 힘 적용 안 함
        if (a.pinned) {
          continue;
        }
        if (b.pinned) {
          continue;
        }
        let dx = b.x - a.x;
        let dy = b.y - a.y;
        const dist = Math.sqrt(dx * dx + dy * dy) || 1;
        const minDist = (a.r + b.r) * 4.5;
        if (dist > minDist * 3) continue; // 너무 멀면 무시
        const force = (minDist * minDist) / (dist * dist + 1) * 0.6;
        dx /= dist;
        dy /= dist;
        if (!a.fixed) { a.vx -= dx * force; a.vy -= dy * force; }
        if (!b.fixed) { b.vx += dx * force; b.vy += dy * force; }
      }
    }

    // --- 스프링 ---
    edges.forEach((edge) => {
      const source = nodes.find((n) => n.id === edge.source);
      const target = nodes.find((n) => n.id === edge.target);
      if (!source || !target) return;

      let dx = target.x - source.x;
      let dy = target.y - source.y;
      const dist = Math.sqrt(dx * dx + dy * dy) || 1;
      const restLen = source.level === 0 ? 175 : 130;
      const spring = (dist - restLen) * 0.055;
      dx /= dist;
      dy /= dist;

      if (!source.fixed && !source.pinned && source.id !== draggingNodeId.value) {
        source.vx += dx * spring;
        source.vy += dy * spring;
      }
      if (!target.fixed && !target.pinned && target.id !== draggingNodeId.value) {
        target.vx -= dx * spring;
        target.vy -= dy * spring;
      }
    });

    // --- 통합 ---
    nodes.forEach((node) => {
      if (node.pinned) {
        node.vx = 0;
        node.vy = 0;
        return;
      }

      if (node.id === draggingNodeId.value) return;

      const cx = graphWidth / 2;
      const cy = graphHeight / 2;
      node.vx += (cx - node.x) * 0.0008;
      node.vy += (cy - node.y) * 0.0008;

      node.vx *= 0.88;
      node.vy *= 0.88;

      node.x += node.vx;
      node.y += node.vy;

      const pad = node.r + 10;
      node.x = Math.min(graphWidth - pad, Math.max(pad, node.x));
      node.y = Math.min(graphHeight - pad, Math.max(pad, node.y));
    });

    graphNodes.value = [...nodes];
    graphAnimationFrame = requestAnimationFrame(tick);
  };

  graphAnimationFrame = requestAnimationFrame(tick);
};

watch(
  () => showGraphModal.value,
  (isOpen) => {
    if (!isOpen) {
      stopGraphSimulation();
      return;
    }
    // openGraphModal에서 loadAllRelationsForGraph 후 allRelations가 세팅되면
    // allRelations watcher가 시뮬레이션을 시작하므로 여기서는 시뮬레이션만
    graphNodes.value = graphData.value.nodes.map((node) => ({ ...node }));
    graphEdges.value = graphData.value.edges.map((edge) => ({ ...edge }));
    startGraphSimulation();
  },
);

watch(
  () => allRelations.value,
  () => {
    if (!showGraphModal.value) return;
    graphNodes.value = graphData.value.nodes.map((node) => ({ ...node }));
    graphEdges.value = graphData.value.edges.map((edge) => ({ ...edge }));
    startGraphSimulation();
  },
  { deep: true },
);

onMounted(() => {
  // 탭 진입 시 바로 내 인맥을 불러오도록 추가
  void loadRelations();
  void loadAllRelationsForGraph();
  window.addEventListener("mousemove", handleGlobalMouseMove);
  window.addEventListener("mouseup", stopDragging);
});

onBeforeUnmount(() => {
  stopGraphSimulation();
  window.removeEventListener("mousemove", handleGlobalMouseMove);
  window.removeEventListener("mouseup", stopDragging);
});

function createPanelState(): SearchPanelState {
  return {
    searchInput: "",
    searchQuery: "",
    currentPage: 1,
    sliderValue: 1,
    total: 0,
    totalPages: 1,
    items: [],
    loading: false,
  };
}

function getPanelState(key: TargetKey) {
  if (!panelStates[key]) {
    panelStates[key] = createPanelState();
  }
  return panelStates[key];
}

const getOtherUser = (relation: any) => {
  const u1 = relation?.user1;
  const u2 = relation?.user2;
  const me = myUserNo.value;

  if (me && u1?.user_no === me) return u2 || null;
  if (me && u2?.user_no === me) return u1 || null;
  return u2 || u1 || null;
};

const getRelationTargetUser = (relation: any) =>
  getOtherUser(relation) || relation?.user2 || relation?.user1 || null;

const roleLabel = (roleId?: string) => {
  if (roleId === "T") return "선생님";
  if (roleId === "P") return "학부모";
  if (roleId === "S") return "학생";
  return "미확인";
};

const relationBadgeLabel = (relation: any) => {
  const otherRoleId = String(getOtherUser(relation)?.role_id || "");
  const relationTypeId = String(relation?.relation_type_id || "");

  if (relationTypeId === "FRIEND") {
    return "친구";
  }

  if (relationTypeId === "PARENT_CHILD" || relationTypeId === "CHILD_PARENT") {
    if (userRoleId.value === "S") return "부모";
    if (userRoleId.value === "P") return "자녀";
    return otherRoleId === "S" ? "학생" : roleLabel(otherRoleId);
  }

  if (
    relationTypeId === "PUPIL_TEACHER" ||
    relationTypeId === "TEACHER_PUPIL"
  ) {
    if (userRoleId.value === "S") return "선생";
    if (userRoleId.value === "T") return "학생";
    return otherRoleId === "T" ? "선생님" : roleLabel(otherRoleId);
  }

  if (otherRoleId === "T") {
    return userRoleId.value === "S" ? "선생" : "선생님";
  }

  if (otherRoleId === "P") {
    return userRoleId.value === "S" ? "부모" : "학부모";
  }

  if (otherRoleId === "S") {
    return userRoleId.value === "P" ? "자녀" : "학생";
  }

  return relation?.relation_type?.description || "관계 없음";
};

const loadRelations = async () => {
  try {
    relationLoading.value = true;
    const data = await $fetch(`${apiBase.value}/dashboard/relations`, {
      headers: getAuthHeader(),
      query: {
        q: relationSearchQuery.value,
        target: activeTargetKey.value || undefined,
        page: relationCurrentPage.value,
        limit: relationPageSize,
      },
    });
    const response = data as {
      items: any[];
      total: number;
      page: number;
      totalPages: number;
      limit: number;
    };

    relations.value = response.items ?? [];
    relationTotal.value = Number(response.total ?? 0);
    relationCurrentPage.value =
      Number(response.page ?? relationCurrentPage.value) || 1;
    relationTotalPages.value = Number(response.totalPages ?? 1) || 1;
    relationSliderValue.value = relationCurrentPage.value;
  } catch (err) {
    console.error("서버 통신 오류(fetch) relations:", err);
  } finally {
    relationLoading.value = false;
  }
};

const applyRelationSearch = async () => {
  relationSearchQuery.value = relationSearchInput.value.trim();
  relationCurrentPage.value = 1;
  relationSliderValue.value = 1;
  await loadRelations();
  if (activeTargetKey.value) {
    const panel = getPanelState(activeTargetKey.value);
    panel.searchInput = relationSearchInput.value;
    panel.searchQuery = relationSearchQuery.value;
    panel.currentPage = 1;
    panel.sliderValue = 1;
    await fetchCandidates(activeTargetKey.value);
  }
};

const clearRelationSearch = async () => {
  relationSearchInput.value = "";
  relationSearchQuery.value = "";
  relationCurrentPage.value = 1;
  relationSliderValue.value = 1;
  await loadRelations();
  if (activeTargetKey.value) {
    const panel = getPanelState(activeTargetKey.value);
    panel.searchInput = "";
    panel.searchQuery = "";
    panel.currentPage = 1;
    panel.sliderValue = 1;
    await fetchCandidates(activeTargetKey.value);
  }
};

const handleRelationSliderInput = (event: Event) => {
  const value = Number((event.target as HTMLInputElement).value);
  if (hasConnectedRelations.value) {
    relationSliderValue.value = value;
    return;
  }
  if (activePanel.value) {
    activePanel.value.sliderValue = value;
  }
};

const commitRelationSliderValue = async () => {
  if (hasConnectedRelations.value) {
    relationCurrentPage.value = Math.min(
      Math.max(relationSliderValue.value, 1),
      relationTotalPagesComputed.value,
    );
    await loadRelations();
    return;
  }
  if (!activePanel.value || !activeTargetKey.value) return;
  activePanel.value.currentPage = Math.min(
    Math.max(activePanel.value.sliderValue, 1),
    mainDisplayTotalPages.value,
  );
  await fetchCandidates(activeTargetKey.value);
};

const fetchCandidates = async (targetKey = activeTargetKey.value) => {
  if (!targetKey) return;
  const target = relationTargets.value.find((item) => item.key === targetKey);
  if (!target) return;

  const panel = getPanelState(targetKey);
  panel.loading = true;

  try {
    const data = await $fetch(
      `${apiBase.value}/dashboard/relations/candidates`,
      {
        headers: getAuthHeader(),
        query: {
          role: target.roleId,
          q: panel.searchQuery,
          page: panel.currentPage,
          limit: pageSize,
        },
      },
    );

    const response = data as {
      items: any[];
      total: number;
      page: number;
      totalPages: number;
      limit: number;
    };

    panel.items = response.items ?? [];
    panel.total = Number(response.total ?? 0);
    panel.currentPage = Number(response.page ?? panel.currentPage) || 1;
    panel.totalPages = Number(response.totalPages ?? 1) || 1;
    panel.sliderValue = panel.currentPage;
  } catch (err) {
    console.error("서버 통신 오류(fetch) relation candidates:", err);
    panel.items = [];
    panel.total = 0;
    panel.totalPages = 1;
  } finally {
    panel.loading = false;
  }
};

const openConnectModal = () => {
  if (relationTargets.value.length === 0) return;
  showConnectModal.value = true;
  if (!activeTargetKey.value) {
    activeTargetKey.value = relationTargets.value[0].key;
  }
  feedbackMessage.value = "";
  void fetchCandidates(activeTargetKey.value);
};

const closeConnectModal = () => {
  showConnectModal.value = false;
  feedbackMessage.value = "";
};

const selectTarget = async (targetKey: TargetKey) => {
  if (activeTargetKey.value === targetKey) return;
  activeTargetKey.value = targetKey;
  if (showConnectModal.value) {
    const panel = getPanelState(targetKey);
    panel.currentPage = 1;
    panel.sliderValue = 1;
    await fetchCandidates(targetKey);
  }
};

const applySearch = async () => {
  if (!activeTargetKey.value) return;
  const panel = getPanelState(activeTargetKey.value);
  panel.searchQuery = panel.searchInput.trim();
  panel.currentPage = 1;
  panel.sliderValue = 1;
  await fetchCandidates(activeTargetKey.value);
};

const clearSearch = async () => {
  if (!activeTargetKey.value) return;
  const panel = getPanelState(activeTargetKey.value);
  panel.searchInput = "";
  panel.searchQuery = "";
  panel.currentPage = 1;
  panel.sliderValue = 1;
  await fetchCandidates(activeTargetKey.value);
};

const handleSliderInput = (event: Event) => {
  if (!activePanel.value) return;
  activePanel.value.sliderValue = Number(
    (event.target as HTMLInputElement).value,
  );
};

const commitSliderValue = async () => {
  if (!activePanel.value || !activeTargetKey.value) return;
  const panel = activePanel.value;
  panel.currentPage = Math.min(
    Math.max(panel.sliderValue, 1),
    totalPages.value,
  );
  await fetchCandidates(activeTargetKey.value);
};

const toggleCandidateRelation = async (user: any, event: Event) => {
  if (!activeTarget.value) return;
  const checked = (event.target as HTMLInputElement).checked;
  submittingUserId.value = String(user.user_no);

  try {
    const result = checked
      ? await $fetch(`${apiBase.value}/dashboard/relations`, {
          method: "POST",
          headers: getAuthHeader(),
          body: {
            targetUserNo: user.user_no,
            targetRoleId: activeTarget.value.roleId,
          },
        })
      : await $fetch(`${apiBase.value}/dashboard/relations/${user.user_no}`, {
          method: "DELETE",
          headers: getAuthHeader(),
        });

    feedbackMessage.value =
      (result as { message?: string }).message ||
      (checked
        ? `${user.username} 님과 연결했습니다.`
        : `${user.username} 님과의 연결을 해제했습니다.`);
    await loadRelations();
    await fetchCandidates(activeTarget.value.key);
    // 그래프 데이터도 갱신
    void loadAllRelationsForGraph();
  } catch (err: any) {
    const message =
      err?.data?.message || err?.message || "연결에 실패했습니다.";
    feedbackMessage.value = String(message);
  } finally {
    submittingUserId.value = "";
  }
};

watch(
  relationTargets,
  (targets) => {
    if (targets.length === 0) {
      activeTargetKey.value = "";
      return;
    }

    if (!targets.some((target) => target.key === activeTargetKey.value)) {
      activeTargetKey.value = targets[0].key;
    }
  },
  { immediate: true },
);

watch(
  () => activeTargetKey.value,
  async (targetKey, previousKey) => {
    if (!targetKey) return;
    if (targetKey === previousKey) return;
    relationCurrentPage.value = 1;
    relationSliderValue.value = 1;
    const panel = getPanelState(targetKey);
    panel.searchInput = relationSearchInput.value;
    panel.searchQuery = relationSearchQuery.value;
    panel.currentPage = 1;
    panel.sliderValue = 1;
    await loadRelations();
    await fetchCandidates(targetKey);
  },
  { immediate: true },
);

</script>

<template>
  <div class="relation-manager">
    <div class="manager-header">
      <div class="header-copy">
        <h3><IconUsers class="section-icon" /> 나의 인맥 관리</h3>
        <p class="manager-subtitle">{{ relationSummary }}</p>
      </div>
      <div class="header-actions">
        <button class="btn-graph" @click="openGraphModal">
          <IconGraphForce class="graph-icon" />
          그래프로 보기
        </button>
        <div class="target-tabs target-tabs-inline">
          <button
            v-for="target in relationTargets"
            :key="target.key"
            class="target-tab"
            :class="{ active: activeTargetKey === target.key }"
            @click="selectTarget(target.key)"
          >
            {{ target.label }}
          </button>
        </div>
        <button
          class="btn-add"
          :disabled="relationTargets.length === 0"
          @click="openConnectModal"
        >
          + 연결 관리
        </button>
      </div>
    </div>

    <div class="pagination-panel-border">
      <div class="slider-panel">
        <div class="search-row">
          <label class="search-box">
            <IconSearch class="search-icon-svg" />
            <input
              v-model="relationSearchInput"
              type="search"
              placeholder="이름 또는 아이디를 입력하세요"
              @keyup.enter="applyRelationSearch"
            />
          </label>
          <button class="btn-search" @click="applyRelationSearch">검색</button>
          <button
            v-if="relationSearchQuery"
            class="btn-reset-search"
            @click="clearRelationSearch"
          >
            초기화
          </button>
        </div>

        <div class="slider-row">
          <span class="summary-text">총 {{ mainDisplayTotal }}건</span>
          <div class="page-slider-section">
            <div
              class="slider-wrapper"
              :class="{ disabled: mainDisplaySliderDisabled }"
            >
              <span class="slider-limit">1</span>
              <div class="slider-track-container">
                <input
                  type="range"
                  :min="1"
                  :max="mainDisplayTotalPages"
                  :value="mainDisplaySliderValue"
                  class="page-slider"
                  :disabled="mainDisplaySliderDisabled"
                  @input="handleRelationSliderInput"
                  @change="commitRelationSliderValue"
                />
                <div
                  class="slider-fill"
                  :style="{ width: mainDisplaySliderPercentage + '%' }"
                ></div>
                <div
                  class="slider-tooltip"
                  :style="{ left: mainDisplaySliderPercentage + '%' }"
                >
                  {{ mainDisplaySliderValue }}
                </div>
              </div>
              <span class="slider-limit">{{ mainDisplayTotalPages }}</span>
            </div>
          </div>
          <span class="range-text"
            >{{ mainDisplayPageStartItem }}-{{ mainDisplayPageEndItem }}번째 항목 표시
            중</span
          >
        </div>
      </div>
    </div>

    <div v-if="relationLoading" class="loading">불러오는 중...</div>
    <div
      v-else-if="!hasConnectedRelations && !hasCandidateResults"
      class="empty"
    >
      {{
        relationSearchQuery
          ? "검색 결과가 없습니다."
          : "연결된 사용자가 없습니다. 이름으로 찾아서 바로 연결해 보세요."
      }}
    </div>
    <TransitionGroup
      v-else-if="hasConnectedRelations"
      name="relation-slide"
      tag="div"
      class="relation-list"
    >
      <div
        v-for="rel in relations"
        :key="rel.relation_id"
        class="relation-item"
      >
        <div class="relation-row">
          <div class="relation-user">
            <button
              type="button"
              class="user-name-button"
              @click="emit('open-message-thread', getRelationTargetUser(rel))"
            >
              <span class="user-name">{{ getRelationTargetUser(rel)?.username }}</span>
            </button>
            <span class="user-id">{{ getRelationTargetUser(rel)?.user_id }}</span>
          </div>
          <div class="relation-actions">
            <span class="relation-badge">{{ relationBadgeLabel(rel) }}</span>
            <button
              class="relation-message-btn"
              @click="emit('compose-message', getRelationTargetUser(rel))"
            >
              메시지
            </button>
          </div>
        </div>
      </div>
    </TransitionGroup>
    <TransitionGroup
      v-else
      name="candidate-slide"
      tag="div"
      class="candidate-list candidate-list-main"
    >
      <div
        v-for="user in activePanel?.items || []"
        :key="user.user_no"
        class="candidate-item"
      >
        <label class="candidate-row">
          <input
            class="relation-checkbox"
            type="checkbox"
            :checked="user.isConnected"
            :disabled="submittingUserId === user.user_no"
            @change="toggleCandidateRelation(user, $event)"
          />
          <span class="candidate-name">{{ user.username }}</span>
          <span class="candidate-id">{{ user.user_id }}</span>
        </label>
      </div>
    </TransitionGroup>

    <div
      v-if="showConnectModal"
      class="modal-overlay"
      @click.self="closeConnectModal"
    >
      <div class="modal-card">
        <div class="modal-header">
          <div>
            <h2>연결 관리</h2>
            <p class="modal-desc">{{ relationSummary }}</p>
          </div>
          <div class="modal-header-actions">
            <div class="target-tabs">
              <button
                v-for="target in relationTargets"
                :key="target.key"
                class="target-tab"
                :class="{ active: activeTargetKey === target.key }"
                @click="selectTarget(target.key)"
              >
                {{ target.label }}
              </button>
            </div>
            <button class="btn-close" @click="closeConnectModal">
              <IconClose class="close-icon" />
            </button>
          </div>
        </div>

        <div class="modal-body">
          <Transition name="section-slide" mode="out-in">
            <div
              v-if="activeTarget && activePanel"
              :key="activeTarget.key"
              class="target-panel"
            >
              <div class="pagination-panel-border">
                <div class="slider-panel">
                  <div class="search-row">
                    <label class="search-box">
                      <span class="search-icon">⌕</span>
                      <input
                        v-model="activePanel.searchInput"
                        type="search"
                        :placeholder="`${activeTarget.label} 이름 또는 아이디를 입력하세요`"
                        @keyup.enter="applySearch"
                      />
                    </label>
                    <button class="btn-search" @click="applySearch">
                      검색
                    </button>
                    <button
                      v-if="activePanel.searchQuery"
                      class="btn-reset-search"
                      @click="clearSearch"
                    >
                      초기화
                    </button>
                  </div>

                  <div class="slider-row">
                    <span class="summary-text"
                      >총 {{ activePanel.total }}명</span
                    >
                    <div class="page-slider-section">
                      <div
                        class="slider-wrapper"
                        :class="{ disabled: isSliderDisabled }"
                      >
                        <span class="slider-limit">1</span>
                        <div class="slider-track-container">
                          <input
                            type="range"
                            :min="1"
                            :max="totalPages"
                            :value="activePanel.sliderValue"
                            class="page-slider"
                            :disabled="isSliderDisabled"
                            @input="handleSliderInput"
                            @change="commitSliderValue"
                          />
                          <div
                            class="slider-fill"
                            :style="{ width: sliderPercentage + '%' }"
                          ></div>
                          <div
                            class="slider-tooltip"
                            :style="{ left: sliderPercentage + '%' }"
                          >
                            {{ activePanel.sliderValue }}
                          </div>
                        </div>
                        <span class="slider-limit">{{ totalPages }}</span>
                      </div>
                    </div>
                    <span class="range-text"
                      >{{ pageStartItem }}-{{ pageEndItem }}번째 항목 표시
                      중</span
                    >
                  </div>
                </div>
              </div>

              <div v-if="activePanel.loading" class="loading compact">
                불러오는 중...
              </div>
              <div v-else-if="activePanel.total === 0" class="empty compact">
                검색 결과가 없습니다.
              </div>
              <TransitionGroup
                v-else
                name="candidate-slide"
                tag="div"
                class="candidate-list"
              >
                <div
                  v-for="user in activePanel.items"
                  :key="user.user_no"
                  class="candidate-item"
                >
                  <label class="candidate-row">
                    <input
                      class="relation-checkbox"
                      type="checkbox"
                      :checked="user.isConnected"
                      :disabled="submittingUserId === user.user_no"
                      @change="toggleCandidateRelation(user, $event)"
                    />
                    <span class="candidate-name">{{ user.username }}</span>
                    <span class="candidate-id">{{ user.user_id }}</span>
                  </label>
                </div>
              </TransitionGroup>

              <p v-if="feedbackMessage" class="feedback-message">
                {{ feedbackMessage }}
              </p>
            </div>
          </Transition>
        </div>
      </div>
    </div>

    <div
      v-if="showGraphModal"
      class="graph-modal-overlay"
      @click.self="closeGraphModal"
    >
      <div class="graph-modal-card">
        <div class="graph-modal-header">
          <div>
            <h2>인맥 네트워크</h2>
            <p class="graph-modal-desc">
              현재 연결된 인맥을 포스 레이아웃으로 시각화했습니다.
            </p>
          </div>
          <button class="btn-close" @click="closeGraphModal">
            <IconClose class="close-icon" />
          </button>
        </div>

        <div v-if="graphLoading" class="graph-empty">
          인맥 그래프를 불러오는 중...
        </div>
        <div v-else-if="graphNodes.length <= 1" class="graph-empty">
          아직 시각화할 인맥이 없습니다. 먼저 친구나 관계를 연결해 보세요.
        </div>

        <div v-else class="graph-stage">
          <svg
            class="graph-svg"
            :viewBox="`0 0 ${graphWidth} ${graphHeight}`"
            role="img"
            aria-label="인맥 네트워크 그래프"
          >
            <defs>
              <!-- 글로우 필터: 호버 시 빛나게 -->
              <filter id="glow-sm" x="-50%" y="-50%" width="200%" height="200%">
                <feGaussianBlur stdDeviation="4" result="blur" />
                <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
              </filter>
              <filter id="glow-md" x="-80%" y="-80%" width="260%" height="260%">
                <feGaussianBlur stdDeviation="8" result="blur" />
                <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
              </filter>
            </defs>

            <!-- 엣지 -->
            <g class="graph-links">
              <line
                v-for="edge in graphEdgePositions"
                :key="`${edge.source}-${edge.target}`"
                :x1="edge.x1" :y1="edge.y1"
                :x2="edge.x2" :y2="edge.y2"
                :class="edge.isGroupEdge ? 'graph-edge-main' : 'graph-edge-sub'"
              />
            </g>

            <!-- 노드 -->
            <g class="graph-nodes">
              <g
                v-for="node in graphNodes"
                :key="node.id"
                class="graph-node-g"
                :transform="`translate(${node.x}, ${node.y})`"
                @mouseenter="hoveredGraphNodeId = node.id"
                @mouseleave="hoveredGraphNodeId = ''"
                style="cursor:default"
              >
                <!-- 호버 글로우 링 -->
                <circle
                  v-if="hoveredGraphNodeId === node.id"
                  :r="node.r + 10"
                  class="graph-node-halo-ring"
                  :filter="node.level === 0 ? 'url(#glow-md)' : 'url(#glow-sm)'"
                />
                <!-- 메인 원 -->
                <circle
                  :r="hoveredGraphNodeId === node.id ? node.r * 1.22 : node.r"
                  class="graph-node-circle"
                  :class="[
                    node.level === 0 ? 'node-me' :
                    node.level === 1 ? 'node-group' : 'node-person'
                  ,hoveredGraphNodeId === node.id ? 'node-hovered' : '',
                  draggingNodeId === node.id ? 'node-dragging' : '']"
                  @mousedown.prevent="startDragging(node.id)"
                />
                <!-- 라벨 -->
                <text
                  class="graph-node-label"
                  :class="node.level === 0 ? 'label-me' : node.level === 1 ? 'label-group' : 'label-person'"
                  y="0.35em"
                >
                  {{ node.label }}
                </text>
              </g>
            </g>
          </svg>

          <!-- 호버 툴팁 (선택된 노드 정보) -->
          <Transition name="tooltip-fade">
            <div
              v-if="hoveredGraphNodeId"
              class="graph-tooltip"
            >
              <span class="graph-tooltip-label">
                {{ graphNodes.find(n => n.id === hoveredGraphNodeId)?.label }}
              </span>
              <span class="graph-tooltip-level">
                {{
                  graphNodes.find(n => n.id === hoveredGraphNodeId)?.level === 0 ? '나' :
                  graphNodes.find(n => n.id === hoveredGraphNodeId)?.level === 1 ? '그룹' : '구성원'
                }}
              </span>
            </div>
          </Transition>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.relation-manager {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.manager-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.header-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 0.5rem;
  margin-left: auto;
  flex-wrap: wrap;
}

.header-copy {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.manager-header h3 {
  color: #f8fafc;
  margin: 0;
  font-size: 1.25rem;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.section-icon,
.search-icon-svg,
.close-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.manager-subtitle {
  color: #94a3b8;
  margin: 0;
  font-size: 0.92rem;
}

.btn-graph {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.55rem 0.9rem;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.08);
  color: #e2e8f0;
  border: 1px solid rgba(255, 255, 255, 0.14);
  cursor: pointer;
  font-weight: 800;
  transition: transform 0.18s ease, border-color 0.18s ease,
    background 0.18s ease, color 0.18s ease;
}

.btn-graph:hover {
  transform: translateY(-1px);
  border-color: rgba(129, 140, 248, 0.55);
  background: rgba(129, 140, 248, 0.12);
  color: #ffffff;
}

.graph-icon {
  width: 1rem;
  height: 1rem;
}

.btn-add {
  background: #818cf8;
  color: white;
  border: none;
  padding: 0.62rem 1.15rem;
  border-radius: 10px;
  font-weight: 700;
  cursor: pointer;
  transition:
    transform 0.2s,
    opacity 0.2s,
    background 0.2s;
  white-space: nowrap;
}

.btn-add:hover:not(:disabled) {
  background: #6366f1;
  transform: translateY(-1px);
}

.btn-add:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.relation-list {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 0.9rem;
}

.relation-item {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 12px;
  padding: 0.5rem 0.65rem;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 0.4rem;
  transition:
    transform 0.2s,
    border-color 0.2s;
  min-height: 46px;
}

.relation-item:hover {
  transform: translateY(-2px);
  border-color: rgba(129, 140, 248, 0.45);
}

.relation-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  min-width: 0;
  width: 100%;
}

.relation-user {
  display: flex;
  align-items: baseline;
  gap: 0.45rem;
  min-width: 0;
  overflow: hidden;
}

.relation-actions {
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
  flex-shrink: 0;
}

.relation-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.16rem 0.5rem;
  border-radius: 999px;
  background: rgba(129, 140, 248, 0.12);
  color: #a5b4fc;
  font-size: 0.7rem;
  font-weight: 800;
  white-space: nowrap;
  flex-shrink: 0;
}

.relation-message-btn {
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.05);
  color: #e2e8f0;
  border-radius: 999px;
  padding: 0.18rem 0.55rem;
  font-size: 0.72rem;
  font-weight: 800;
  cursor: pointer;
}

.relation-message-btn:hover {
  background: rgba(129, 140, 248, 0.14);
  border-color: rgba(129, 140, 248, 0.28);
}

.user-name {
  font-weight: 700;
  color: #c7d2fe;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.user-name-button {
  background: none;
  border: none;
  padding: 0;
  cursor: pointer;
  text-align: left;
  min-width: 0;
}

.user-name-button:hover .user-name {
  text-decoration: underline;
}

.user-id {
  color: #94a3b8;
  font-size: 0.8rem;
  font-weight: 600;
  white-space: nowrap;
  flex-shrink: 0;
}

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(2, 6, 23, 0.78);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
}

.graph-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(2, 6, 23, 0.82);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1100;
  padding: 1rem;
}

.graph-modal-card {
  width: min(980px, 100%);
  max-height: 88vh;
  background:
    radial-gradient(circle at top, rgba(99, 102, 241, 0.2), transparent 30%),
    linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 18px;
  box-shadow: 0 28px 80px -30px rgba(0, 0, 0, 0.75);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.graph-modal-header {
  padding: 1rem 1.2rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.graph-modal-header h2 {
  margin: 0;
  color: #f8fafc;
  font-size: 1.28rem;
  font-weight: 800;
}

.graph-modal-desc {
  margin: 0.35rem 0 0;
  color: #94a3b8;
  font-size: 0.92rem;
}

.graph-stage {
  padding: 1rem;
  position: relative;
}

.graph-svg {
  width: 100%;
  height: min(68vh, 560px);
  display: block;
  border-radius: 16px;
  background:
    radial-gradient(ellipse at 50% 40%, rgba(99, 102, 241, 0.13) 0%, transparent 60%),
    linear-gradient(180deg, rgba(15, 23, 42, 0.9), rgba(10, 15, 35, 0.99));
}

/* 엣지 스타일 */
.graph-edge-main {
  stroke: rgba(129, 140, 248, 0.55);
  stroke-width: 2;
  stroke-linecap: round;
  stroke-dasharray: none;
}
.graph-edge-sub {
  stroke: rgba(129, 140, 248, 0.28);
  stroke-width: 1.5;
  stroke-linecap: round;
  stroke-dasharray: 4 3;
}

/* 노드 그룹 */
.graph-node-g {
  transition: none; /* 위치는 JS로 처리 */
}

.graph-node-circle {
  transition: r 0.18s cubic-bezier(0.34, 1.56, 0.64, 1),
              opacity 0.18s ease;
}

/* 레벨별 원 색상 */
.node-me {
  fill: #818cf8;
  opacity: 0.97;
}
.node-group {
  fill: #6366f1;
  opacity: 0.82;
}
.node-person {
  fill: #818cf8;
  opacity: 0.72;
}
.node-hovered {
  opacity: 1 !important;
}
.node-dragging {
  stroke: rgba(255, 255, 255, 0.6);
  stroke-width: 2.5;
  cursor: grabbing !important;
}

/* 글로우 링 */
.graph-node-halo-ring {
  fill: rgba(129, 140, 248, 0.22);
  stroke: rgba(129, 140, 248, 0.5);
  stroke-width: 1.5;
}

/* 라벨 */
.graph-node-label {
  text-anchor: middle;
  dominant-baseline: central;
  pointer-events: none;
  user-select: none;
}
.label-me {
  fill: #ffffff;
  font-size: 26px;
  font-weight: 800;
}
.label-group {
  fill: #e0e7ff;
  font-size: 11px;
  font-weight: 700;
}
.label-person {
  fill: #c7d2fe;
  font-size: 10px;
  font-weight: 600;
}

/* 툴팁 */
.graph-tooltip {
  position: absolute;
  bottom: 1.5rem;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(30, 41, 59, 0.95);
  border: 1px solid rgba(129, 140, 248, 0.35);
  border-radius: 10px;
  padding: 0.45rem 1rem;
  display: flex;
  align-items: center;
  gap: 0.6rem;
  pointer-events: none;
  backdrop-filter: blur(8px);
  box-shadow: 0 8px 32px rgba(99, 102, 241, 0.2);
}
.graph-tooltip-label {
  color: #f1f5f9;
  font-size: 0.88rem;
  font-weight: 700;
}
.graph-tooltip-level {
  color: #818cf8;
  font-size: 0.78rem;
  font-weight: 700;
  padding: 0.1rem 0.5rem;
  background: rgba(129, 140, 248, 0.15);
  border-radius: 999px;
}

.tooltip-fade-enter-active,
.tooltip-fade-leave-active {
  transition: opacity 0.18s ease, transform 0.18s ease;
}
.tooltip-fade-enter-from,
.tooltip-fade-leave-to {
  opacity: 0;
  transform: translateX(-50%) translateY(6px);
}

.graph-empty {
  padding: 4rem 1.5rem;
  text-align: center;
  color: #94a3b8;
}

.modal-card {
  width: min(920px, 100%);
  max-height: 88vh;
  background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  box-shadow: 0 28px 80px -30px rgba(0, 0, 0, 0.65);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.modal-header {
  padding: 1rem 1.2rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.modal-header-actions {
  display: flex;
  align-items: flex-start;
  gap: 0.65rem;
  margin-left: auto;
}

.modal-header h2 {
  font-size: 1.25rem;
  color: #f8fafc;
  font-weight: 800;
  margin: 0;
}

.modal-desc {
  margin: 0.35rem 0 0;
  color: #94a3b8;
  font-size: 0.9rem;
}

.btn-close {
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 2rem;
  line-height: 1;
  cursor: pointer;
}

.modal-body {
  padding: 1.2rem;
  overflow-y: auto;
}

.target-tabs {
  display: inline-flex;
  gap: 0.2rem;
  padding: 0.18rem;
  margin-bottom: 0;
  align-items: center;
  flex-wrap: wrap;
  border-radius: 8px;
  background: rgba(15, 23, 42, 0.55);
  border: 1px solid rgba(148, 163, 184, 0.14);
}

.target-tabs-inline {
  justify-content: flex-end;
}

.target-tab {
  border: none;
  background: transparent;
  color: #94a3b8;
  font-size: 0.88rem;
  font-weight: 700;
  border-radius: 6px;
  padding: 0 0.7rem;
  height: 28px;
  line-height: 28px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  transition: all 0.2s ease;
}

.target-tab:hover {
  color: #e2e8f0;
  background: rgba(255, 255, 255, 0.04);
}

.target-tab.active {
  background: #6d6eff;
  color: #ffffff;
  box-shadow: 0 8px 18px rgba(109, 110, 255, 0.25);
}

.target-panel {
  display: flex;
  flex-direction: column;
  gap: 0.95rem;
}

.target-copy {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.target-eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  color: #a5b4fc;
  font-size: 0.8rem;
  font-weight: 800;
  letter-spacing: 0.02em;
  text-transform: uppercase;
}

.target-copy p {
  margin: 0.35rem 0 0;
  color: #cbd5e1;
  font-size: 0.92rem;
}

.pagination-panel-border {
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 12px;
  padding: 1rem 1.05rem;
  background: rgba(15, 23, 42, 0.72);
  box-shadow: 0 20px 60px -22px rgba(15, 23, 42, 1);
}

.slider-panel {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.search-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.search-box {
  flex: 1;
  min-width: 220px;
  display: flex;
  align-items: center;
  gap: 0.55rem;
  background: rgba(15, 23, 42, 0.56);
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 10px;
  padding: 0.65rem 0.9rem;
}

.search-box input {
  width: 100%;
  background: transparent;
  border: none;
  color: #e2e8f0;
  outline: none;
}

.search-box input::placeholder {
  color: #64748b;
}

.search-icon-svg {
  color: #94a3b8;
}

.btn-search,
.btn-reset-search,
.btn-secondary,
.btn-connect {
  border: none;
  border-radius: 10px;
  padding: 0.58rem 1rem;
  font-weight: 700;
  cursor: pointer;
}

.btn-search {
  background: #6366f1;
  color: #fff;
}

.btn-search:hover {
  background: #4f46e5;
}

.btn-reset-search,
.btn-secondary {
  background: rgba(255, 255, 255, 0.08);
  color: #e2e8f0;
  border: 1px solid rgba(255, 255, 255, 0.12);
}

.slider-row {
  display: flex;
  align-items: center;
  gap: 0.9rem;
  justify-content: space-between;
  flex-wrap: nowrap;
}

.summary-text,
.range-text {
  font-size: 0.85rem;
  color: #cbd5f5;
  font-weight: 500;
  white-space: nowrap;
  flex-shrink: 0;
}

.page-slider-section {
  flex: 1;
  min-width: 0;
}

.slider-wrapper {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  width: 100%;
}

.slider-wrapper.disabled {
  pointer-events: none;
  opacity: 0.6;
}

.slider-limit {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: 700;
  min-width: 20px;
  text-align: center;
}

.slider-track-container {
  position: relative;
  flex: 1;
  height: 32px;
  display: flex;
  align-items: center;
}

.page-slider {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 6px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
  outline: none;
  cursor: pointer;
  z-index: 2;
  position: relative;
  touch-action: none;
}

.page-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 20px;
  height: 20px;
  background: #6366f1;
  border-radius: 50%;
  cursor: pointer;
  box-shadow: 0 0 15px rgba(99, 102, 241, 0.4);
  border: 2px solid #fff;
  transition: transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.page-slider:hover::-webkit-slider-thumb {
  transform: scale(1.15);
  box-shadow: 0 0 20px rgba(99, 102, 241, 0.6);
}

.slider-fill {
  position: absolute;
  height: 6px;
  background: linear-gradient(90deg, #6366f1, #a855f7);
  border-radius: 3px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  z-index: 1;
}

.slider-tooltip {
  position: absolute;
  top: -24px;
  transform: translateX(-50%);
  background: #6366f1;
  color: white;
  padding: 2px 8px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 800;
  pointer-events: none;
  white-space: nowrap;
}

.slider-tooltip::after {
  content: "";
  position: absolute;
  bottom: -4px;
  left: 50%;
  transform: translateX(-50%);
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-top: 4px solid #6366f1;
}

.candidate-list {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 0.7rem;
}

.candidate-list-main {
  margin-top: 0.25rem;
}

.candidate-item {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 12px;
  padding: 0.5rem 0.65rem;
  min-height: 44px;
  display: flex;
  align-items: center;
}

.candidate-name {
  color: #c7d2fe;
  margin: 0;
  font-size: 1rem;
  font-weight: 700;
  min-width: 0;
}

.candidate-id {
  color: #94a3b8;
  font-size: 0.82rem;
  font-weight: 600;
  white-space: nowrap;
  flex-shrink: 0;
}

.candidate-row {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 0.5rem;
  min-width: 0;
  width: 100%;
  overflow: hidden;
}

.relation-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.16rem 0.5rem;
  border-radius: 999px;
  background: rgba(129, 140, 248, 0.12);
  color: #a5b4fc;
  font-size: 0.7rem;
  font-weight: 800;
  white-space: nowrap;
  flex-shrink: 0;
}

.feedback-message {
  margin: 0.1rem 0 0;
  color: #cbd5e1;
  font-size: 0.9rem;
  padding-left: 0.2rem;
}

.loading,
.empty {
  text-align: center;
  padding: 2rem 1rem;
  color: #64748b;
}

.compact {
  padding-top: 1.2rem;
  padding-bottom: 1.2rem;
}

.section-slide-enter-active,
.section-slide-leave-active {
  transition:
    opacity 0.22s ease,
    transform 0.22s ease;
}

.section-slide-enter-from,
.section-slide-leave-to {
  opacity: 0;
  transform: translateX(18px);
}

.candidate-slide-enter-active,
.candidate-slide-leave-active,
.candidate-slide-move,
.relation-slide-enter-active,
.relation-slide-leave-active,
.relation-slide-move {
  transition:
    opacity 0.22s ease,
    transform 0.22s ease;
}

.candidate-slide-enter-from,
.candidate-slide-leave-to,
.relation-slide-enter-from,
.relation-slide-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

@media (max-width: 760px) {
  .relation-list {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .manager-header,
  .target-copy,
  .slider-row {
    flex-direction: column;
    align-items: flex-start;
  }

  .header-actions {
    width: 100%;
    justify-content: flex-start;
  }

  .modal-card {
    max-height: 92vh;
  }

  .search-box,
  .page-slider-section {
    width: 100%;
  }

  .candidate-list {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .modal-header {
    align-items: flex-start;
  }

  .modal-header-actions {
    flex-wrap: wrap;
    justify-content: flex-end;
  }

  .target-tabs {
    justify-content: flex-end;
  }

  .target-tabs-inline {
    justify-content: flex-start;
  }

  .range-text {
    align-self: flex-end;
  }
}

@media (max-width: 480px) {
  .relation-list {
    grid-template-columns: repeat(1, minmax(0, 1fr));
  }

  .candidate-list {
    grid-template-columns: repeat(1, minmax(0, 1fr));
  }
}
</style>
