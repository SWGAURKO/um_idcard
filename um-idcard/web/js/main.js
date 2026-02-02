import { fetchNui } from './fetchNui.js';
import { Global } from '../../lang/global.js';

let config;

/**
 * Get element by id
 * @param id {string}
 **/
const getElementById = (id) => document.getElementById(id);

/**
 * Set visibility 
 * @param visibility {string}
 **/
const setVisibility = (visibility) => getElementById('um-idcard').style.visibility = visibility;

/**
 * Set visibility of badge 
 * @param badge {string|Object|null}
 **/
const setBadgeVisibility = (badge) => {
  const badgeElement = getElementById('badge');
  if (!badge || badge === 'none') {
    badgeElement.style.display = 'none';
    return;
  }
  getElementById('badgeimg').src = `badges/${badge.img}.png`;
  getElementById('badgegrade').textContent = badge.grade;
  badgeElement.style.display = 'flex';
};

const closeFunction = () => {
  getElementById('um-idcard').classList.remove('animate__animated', 'animate__fadeInLeft', 'animate__faster');
  setVisibility('hidden');
  setBadgeVisibility('none');
  fetchNui('closeIdCard');
};

/**
 * Open id card
 * @param playerData {Object}
 **/
const openIdCard = (playerData) => {
  if (!config?.Licenses) {
    console.error('um-idcard: Config not loaded yet');
    return;
  }
  const license = config.Licenses[playerData?.cardtype];
  if (!license) {
    console.error('um-idcard: No Card Type - cardtype missing or not in config.Licenses', playerData?.cardtype);
    return;
  }
  const first = playerData?.firstname ?? '';
  const last = playerData?.lastname ?? '';
  const elements = {
    lastname: last,
    name: first,
    sign: `${last} ${first}`.trim(),
    dob: playerData?.birthdate ?? '',
    sex: playerData?.sex ?? '',
    nationality: playerData?.nationality ?? '',
    cardtype: license.header,
  };

  Object.entries(elements).forEach(([key, value]) => {
    const el = getElementById(key);
    if (el) el.textContent = value ?? '';
  });

  const mugShot = playerData?.mugShot;
  if (mugShot && typeof mugShot === 'string') {
    getElementById('mugshot').src = mugShot;
    getElementById('smallmugshot').src = mugShot;
  }
  getElementById('um-idcard').style.backgroundColor = license.background;
  getElementById('um-idcard').classList.add('animate__animated', 'animate__fadeInLeft', 'animate__faster');
  setBadgeVisibility(playerData.badge);
  setVisibility('visible');
  autoClose();
};

const autoClose = () => {
  if (!config?.IdCardSettings?.autoClose?.status) return;
  setTimeout(closeFunction, config.IdCardSettings.autoClose.time);
};

window.addEventListener('message', (event) => {
  const { type, playerData, configData } = event.data;
  if (type === 'playerData') {
    openIdCard(playerData);
  } else if (type === 'configData') {
    config = configData;
  }
});

window.addEventListener('load', () => {
  if (typeof Global === 'object' && Global) {
    Object.entries(Global).forEach(([key, value]) => {
      const el = getElementById(key);
      if (el) el.textContent = value ?? '';
    });
  }
});

document.addEventListener('keydown', (e) => {
  const closeKey = config?.IdCardSettings?.closeKey ?? 'Backspace';
  if (e.key !== closeKey && e.key !== 'Escape') return;
  closeFunction();
});

getElementById('close-card')?.addEventListener('click', closeFunction);
